import Darwin
import UIKit
@testable import UIKitNavigationTransitions
import XCTest

@MainActor
final class ResponderPolicyTests: XCTestCase {
	func testBaselineCancellationLosesFocus() async throws {
		try await exercise(variant: "baseline", operation: .pop, cancelled: true)
	}

	func testRestoresAfterCancelledPop() async throws {
		try await exercise(operation: .pop, cancelled: true)
	}

	func testRestoresAfterCompletedPush() async throws {
		try await exercise(operation: .push, cancelled: false)
	}

	func testRestoresAfterCompletedPop() async throws {
		try await exercise(operation: .pop, cancelled: false)
	}

	func testDoesNotRestoreIntentionallyDismissedFocus() async throws {
		try await exercise(operation: .pop, cancelled: true, policy: .dismiss)
	}

	func testDoesNotStealTransferredFocus() async throws {
		try await exercise(operation: .pop, cancelled: true, policy: .transfer)
	}

	func testDoesNotStealControllerFocus() async throws {
		try await exercise(operation: .pop, cancelled: true, policy: .transferToController)
	}

	func testDoesNotRestoreRemovedResponder() async throws {
		try await exercise(operation: .pop, cancelled: true, policy: .remove)
	}

	func testDoesNotRestoreDisabledResponder() async throws {
		try await exercise(operation: .pop, cancelled: true, policy: .disable)
	}

	func testDoesNotRestoreIneligibleResponder() async throws {
		try await exercise(operation: .pop, cancelled: true, policy: .ineligible)
	}

	func testLeavesUnfocusedTransitionUnfocused() async throws {
		try await exercise(operation: .pop, cancelled: true, policy: .unfocused)
	}

	private enum Policy { case preserve, dismiss, transfer, transferToController, remove, disable, ineligible, unfocused }

	private func exercise(
		variant: String = "restore-displaced",
		operation: UINavigationController.Operation,
		cancelled: Bool,
		policy: Policy = .preserve,
	) async throws {
		let previousVariant = getenv("NAVIGATION_AB_VARIANT").map { String(cString: $0) }
		let previousLegacy = getenv("NAVIGATION_AB_FORCE_LEGACY").map { String(cString: $0) }
		setenv("NAVIGATION_AB_VARIANT", variant, 1)
		if #available(iOS 17, tvOS 17, *) {
			setenv("NAVIGATION_AB_FORCE_LEGACY", "1", 1)
		} else {
			unsetenv("NAVIGATION_AB_FORCE_LEGACY")
		}
		defer {
			if let previousVariant { setenv("NAVIGATION_AB_VARIANT", previousVariant, 1) }
			else { unsetenv("NAVIGATION_AB_VARIANT") }
			if let previousLegacy { setenv("NAVIGATION_AB_FORCE_LEGACY", previousLegacy, 1) }
			else { unsetenv("NAVIGATION_AB_FORCE_LEGACY") }
		}
		let root = PolicyRootController()
		let host = try await TestWindow(rootViewController: root, test: self)
		defer { host.restore() }
		let context = PolicyContext(cancelled: cancelled)
		context.containerView.frame = host.window.bounds
		root.view.addSubview(context.containerView)
		context.containerView.addSubview(context.from.view)
		let survivor = cancelled ? context.from.view! : context.to.view!
		let field = PolicyResponder(frame: CGRect(x: 30, y: 100, width: 100, height: 50))
		let other = PolicyResponder(frame: CGRect(x: 30, y: 300, width: 100, height: 50))
		survivor.addSubview(field)
		root.view.addSubview(other)
		defer {
			field.onResign = nil
			root.resignFirstResponder()
			root.view.endEditing(true)
		}
		context.onComplete = {
			if policy != .unfocused {
				XCTAssertTrue(field.becomeFirstResponder())
				XCTAssertTrue(field.isFirstResponder)
			}
			if policy == .dismiss { XCTAssertTrue(field.resignFirstResponder()) }
			field.onResign = {
				switch policy {
				case .transfer: XCTAssertTrue(other.becomeFirstResponder())
				case .transferToController:
					root.acceptsFocus = true
					XCTAssertTrue(root.becomeFirstResponder())
				case .remove: field.removeFromSuperview()
				case .disable: field.isEnabled = false
				case .ineligible: field.eligible = false
				default: break
				}
			}
		}
		let provider = NavigationTransitionAnimatorProvider(
			transition: .slide,
			animation: .default,
			operation: operation == .push ? .push : .pop,
		)
		let animator = provider.interruptibleAnimator(using: context)
		animator.startAnimation()
		animator.stopAnimation(false)
		animator.finishAnimation(at: cancelled ? .start : .end)
		XCTAssertEqual(context.completed, !cancelled)
		XCTAssertTrue(survivor.superview === context.containerView)
		XCTAssertTrue(survivor.isUserInteractionEnabled)
		XCTAssertEqual(field.isFirstResponder, variant == "restore-displaced" && policy == .preserve)
		XCTAssertEqual(other.isFirstResponder, policy == .transfer)
		XCTAssertEqual(root.isFirstResponder, policy == .transferToController)
		let expectedAttempts = policy == .unfocused ? 0 : variant == "restore-displaced" && policy == .preserve ? 2 : 1
		XCTAssertEqual(field.attempts, expectedAttempts, "Count rejected acquisition attempts as well as successful ones")
		if policy == .preserve {
			XCTAssertEqual(field.begins, variant == "restore-displaced" ? 2 : 1)
			XCTAssertEqual(field.ends, 1)
		}
		print(
			"[RESPONDER-POLICY] variant=\(variant) operation=\(operation.rawValue) cancelled=\(cancelled) policy=\(policy) firstResponder=\(field.isFirstResponder) attempts=\(field.attempts) begins=\(field.begins) ends=\(field.ends)",
		)
	}
}

@MainActor
private final class PolicyRootController: UIViewController {
	var acceptsFocus = false
	override var canBecomeFirstResponder: Bool { acceptsFocus }
}

@MainActor
private final class PolicyResponder: UIControl {
	var attempts = 0
	var eligible = true
	var begins = 0
	var ends = 0
	var onResign: (() -> Void)? = nil
	override var canBecomeFirstResponder: Bool { eligible }
	override func becomeFirstResponder() -> Bool {
		attempts += 1
		let wasFirst = isFirstResponder
		let result = super.becomeFirstResponder()
		if !wasFirst, isFirstResponder { begins += 1 }
		return result
	}
	override func resignFirstResponder() -> Bool {
		let wasFirst = isFirstResponder
		let result = super.resignFirstResponder()
		if wasFirst, !isFirstResponder {
			ends += 1
			onResign?()
		}
		return result
	}
}

@MainActor
private final class PolicyContext: NSObject, UIViewControllerContextTransitioning {
	let containerView = UIView()
	let from = UIViewController()
	let to = UIViewController()
	let transitionWasCancelled: Bool
	var completed: Bool? = nil
	var onComplete: (() -> Void)? = nil
	var isAnimated: Bool { true }
	var isInteractive: Bool { transitionWasCancelled }
	var presentationStyle: UIModalPresentationStyle { .none }
	var targetTransform: CGAffineTransform { .identity }
	init(cancelled: Bool) { transitionWasCancelled = cancelled }
	func updateInteractiveTransition(_ percentComplete: CGFloat) {}
	func finishInteractiveTransition() {}
	func cancelInteractiveTransition() {}
	func pauseInteractiveTransition() {}
	func completeTransition(_ didComplete: Bool) { completed = didComplete; onComplete?() }
	func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? { key == .from ? from : to
	}
	func view(forKey key: UITransitionContextViewKey) -> UIView? { key == .from ? from.view : to.view }
	func initialFrame(for vc: UIViewController) -> CGRect { containerView.bounds }
	func finalFrame(for vc: UIViewController) -> CGRect { containerView.bounds }
}

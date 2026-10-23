import UIKit
@testable import UIKitNavigationTransitions
import XCTest

@MainActor
final class AnimatorFocusTests: XCTestCase {
	func testCompletionPreservesDestinationFirstResponder() async throws {
		try await checkFocus(cancelled: false)
	}

	func testCancellationPreservesSourceFirstResponder() async throws {
		try await checkFocus(cancelled: true)
	}

	private func checkFocus(cancelled: Bool) async throws {
		guard #available(iOS 17, tvOS 17, *) else {
			throw XCTSkip("iOS 16 retains its legacy view-reattachment workaround")
		}
		let root = UIViewController()
		let host = try await TestWindow(rootViewController: root, test: self)
		defer { host.restore() }
		let window = host.window
		let context = FocusTransitionContext(cancelled: cancelled)
		context.containerView.frame = window.bounds
		root.view.addSubview(context.containerView)
		context.containerView.addSubview(context.from.view)
		let field = FocusResponder(frame: CGRect(x: 20, y: 100, width: 200, height: 50))
		let focusedView = cancelled ? context.from.view! : context.to.view!
		focusedView.addSubview(field)
		let provider = NavigationTransitionAnimatorProvider(transition: .slide, animation: .default, operation: .push)
		let animator = provider.interruptibleAnimator(using: context)
		animator.startAnimation()
		XCTAssertTrue(field.becomeFirstResponder())
		XCTAssertTrue(field.isFirstResponder)
		animator.stopAnimation(false)
		animator.finishAnimation(at: cancelled ? .start : .end)
		XCTAssertEqual(context.completed, !cancelled)
		XCTAssertTrue(field.isFirstResponder)
		XCTAssertTrue(focusedView.superview === context.containerView)
		XCTAssertTrue(focusedView.isUserInteractionEnabled)
	}
}

@MainActor
private final class FocusTransitionContext: NSObject, UIViewControllerContextTransitioning {
	let containerView = UIView()
	let from = UIViewController()
	let to = UIViewController()
	let transitionWasCancelled: Bool
	var completed: Bool? = nil
	var isAnimated: Bool { true }
	var isInteractive: Bool { transitionWasCancelled }
	var presentationStyle: UIModalPresentationStyle { .none }
	var targetTransform: CGAffineTransform { .identity }

	init(cancelled: Bool) { transitionWasCancelled = cancelled }
	func updateInteractiveTransition(_ percentComplete: CGFloat) {}
	func finishInteractiveTransition() {}
	func cancelInteractiveTransition() {}
	func pauseInteractiveTransition() {}
	func completeTransition(_ didComplete: Bool) { completed = didComplete }
	func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? { key == .from ? from : to
	}
	func view(forKey key: UITransitionContextViewKey) -> UIView? { key == .from ? from.view : to.view }
	func initialFrame(for vc: UIViewController) -> CGRect { containerView.bounds }
	func finalFrame(for vc: UIViewController) -> CGRect { containerView.bounds }
}

import UIKit
@testable import UIKitNavigationTransitions
import XCTest

@MainActor
final class InteractiveFocusTests: XCTestCase {
	func testCancelledInteractivePopKeepsFocusedSourceResponsive() async throws {
		let root = UIViewController()
		let source = FocusController()
		let navigation = UINavigationController(rootViewController: root)
		let observer = NavigationObserver()
		navigation.delegate = observer
		navigation.setNavigationTransition(.slide, interactivity: .edgePan)
		let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
		window.rootViewController = navigation
		window.makeKeyAndVisible()
		defer { window.isHidden = true }
		window.layoutIfNeeded()
		let rootVisible = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
			MainActor.assumeIsolated { root.view.window === window }
		}, object: nil)
		await fulfillment(of: [rootVisible], timeout: 3)

		let pushed = expectation(description: "push completed")
		observer.didShow = { controller in
			if controller === source { pushed.fulfill() }
		}
		navigation.pushViewController(source, animated: true)
		await fulfillment(of: [pushed], timeout: 3)
		XCTAssertTrue(source.field.isFirstResponder)

		let interaction = UIPercentDrivenInteractiveTransition()
		let delegate = try XCTUnwrap(navigation.customDelegate)
		delegate.interactionController = interaction
		observer.didShow = nil
		navigation.popViewController(animated: true)
		let coordinator = try XCTUnwrap(navigation.transitionCoordinator)
		XCTAssertTrue(coordinator.isInteractive)
		let started = expectation(description: "interactive pop started")
		let cancelled = expectation(description: "interactive pop cancelled")
		coordinator.animate(alongsideTransition: { _ in started.fulfill() }) { context in
			XCTAssertTrue(context.isCancelled)
			cancelled.fulfill()
		}
		await fulfillment(of: [started], timeout: 3)
		interaction.update(0.3)
		interaction.cancel()
		await fulfillment(of: [cancelled], timeout: 3)
		XCTAssertTrue(navigation.topViewController === source)
		XCTAssertEqual(navigation.viewControllers.count, 2)
		XCTAssertTrue(source.field.isFirstResponder)
		XCTAssertTrue(source.view.isUserInteractionEnabled)
		let center = source.field.convert(CGPoint(x: source.field.bounds.midX, y: source.field.bounds.midY), to: window)
		let hit = try XCTUnwrap(window.hitTest(center, with: nil))
		XCTAssertTrue(hit === source.field || hit.isDescendant(of: source.field))
	}
}

@MainActor
private final class FocusController: UIViewController {
	let field = UITextField(frame: CGRect(x: 20, y: 150, width: 250, height: 50))
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(field)
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		field.becomeFirstResponder()
	}
}

@MainActor
private final class NavigationObserver: NSObject, UINavigationControllerDelegate {
	var didShow: ((UIViewController) -> Void)? = nil
	func navigationController(
		_ navigationController: UINavigationController,
		didShow viewController: UIViewController,
		animated: Bool,
	) {
		didShow?(viewController)
	}
}

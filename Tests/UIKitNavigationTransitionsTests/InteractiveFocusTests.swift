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
		let host = try await TestWindow(rootViewController: navigation, test: self)
		defer { host.restore() }
		let window = host.window

		let pushed = expectation(description: "push completed")
		observer.didShow = { controller in
			if controller === source { pushed.fulfill() }
		}
		navigation.pushViewController(source, animated: true)
		await fulfillment(of: [pushed], timeout: 3)
		XCTAssertTrue(source.field.becomeFirstResponder())
		XCTAssertTrue(source.field.isFirstResponder)

		let interaction = UIPercentDrivenInteractiveTransition()
		let delegate = try XCTUnwrap(navigation.customDelegate)
		delegate.interactionController = interaction
		observer.didShow = nil
		navigation.popViewController(animated: true)
		let coordinator = try XCTUnwrap(navigation.transitionCoordinator)
		XCTAssertTrue(coordinator.viewController(forKey: .from) === source)
		XCTAssertTrue(coordinator.viewController(forKey: .to) === root)
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
		// On iOS 16 and tvOS 16, the reattachment workaround restores responsiveness but causes the first responder to
		// resign.
		if #unavailable(iOS 17, tvOS 17, visionOS 1) {
			XCTAssertFalse(source.field.isFirstResponder)
		} else {
			XCTAssertTrue(source.field.isFirstResponder)
		}
		XCTAssertTrue(source.view.isUserInteractionEnabled)
		let center = source.field.convert(CGPoint(x: source.field.bounds.midX, y: source.field.bounds.midY), to: window)
		let hit = try XCTUnwrap(window.hitTest(center, with: nil))
		XCTAssertTrue(hit === source.field || hit.isDescendant(of: source.field))
	}
}

@MainActor
private final class FocusController: UIViewController {
	let field = FocusResponder()
	override func viewDidLoad() {
		super.viewDidLoad()
		field.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(field)
		NSLayoutConstraint.activate([
			field.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
			field.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
			field.widthAnchor.constraint(equalToConstant: 250),
			field.heightAnchor.constraint(equalToConstant: 50),
		])
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

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
		let host = try await TestWindow(rootViewController: navigation)
		defer { host.restore() }
		let window = host.window

		var pushed = false
		observer.didShow = { controller in
			if controller === source { pushed = true }
		}
		navigation.pushViewController(source, animated: true)
		try await waitUntil { pushed }
		XCTAssertTrue(source.field.becomeFirstResponder())
		XCTAssertTrue(source.field.isFirstResponder)

		let interaction = UIPercentDrivenInteractiveTransition()
		let delegate = try XCTUnwrap(navigation.customDelegate)
		delegate.interactionController = interaction
		observer.didShow = nil
		navigation.popViewController(animated: true)
		let coordinator = try XCTUnwrap(navigation.transitionCoordinator)
		XCTAssertTrue(coordinator.isInteractive)
		var started = false
		var wasCancelled: Bool? = nil
		coordinator.animate(alongsideTransition: { _ in started = true }) { context in
			wasCancelled = context.isCancelled
		}
		try await waitUntil { started }
		interaction.update(0.3)
		interaction.cancel()
		try await waitUntil { wasCancelled != nil }
		XCTAssertEqual(wasCancelled, true)
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

#if !os(tvOS) && !os(visionOS)
import Testing
import UIKit
@testable import UIKitNavigationTransitions

@MainActor
struct GestureRecognizerTests {
	@available(iOS 26, macCatalyst 26, *)
	@Test
	func defaultInteractivityUsesSystemRecognizer() throws {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.default)

		let contentPopGestureRecognizer = try #require(
			navigationController.interactiveContentPopGestureRecognizer
		)

		#expect(navigationController.defaultEdgePanRecognizer.isEnabled)
		#expect(contentPopGestureRecognizer.isEnabled)
		#expect(navigationController.defaultPanRecognizer == nil)
		#expect(!navigationController.edgePanRecognizer.isEnabled)
		#expect(!navigationController.panRecognizer.isEnabled)
	}

	@available(iOS 26, macCatalyst 26, *)
	@Test
	func defaultEdgePanDisablesContentRecognizer() throws {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.default, interactivity: .edgePan)

		let contentPopGestureRecognizer = try #require(
			navigationController.interactiveContentPopGestureRecognizer
		)

		#expect(navigationController.defaultEdgePanRecognizer.isEnabled)
		#expect(!contentPopGestureRecognizer.isEnabled)
		#expect(!navigationController.edgePanRecognizer.isEnabled)
		#expect(!navigationController.panRecognizer.isEnabled)
	}

	@available(iOS 26, macCatalyst 26, *)
	@Test
	func disabledInteractivityDisablesSystemRecognizers() throws {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.default, interactivity: .disabled)

		let contentPopGestureRecognizer = try #require(
			navigationController.interactiveContentPopGestureRecognizer
		)

		#expect(!navigationController.defaultEdgePanRecognizer.isEnabled)
		#expect(!contentPopGestureRecognizer.isEnabled)
		#expect(!navigationController.edgePanRecognizer.isEnabled)
		#expect(!navigationController.panRecognizer.isEnabled)
	}

	@available(iOS 26, macCatalyst 26, *)
	@Test
	func customContentPanUsesCustomRecognizer() throws {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.slide, interactivity: .contentPan)

		let contentPopGestureRecognizer = try #require(
			navigationController.interactiveContentPopGestureRecognizer
		)

		#expect(!navigationController.defaultEdgePanRecognizer.isEnabled)
		#expect(!contentPopGestureRecognizer.isEnabled)
		#expect(!navigationController.edgePanRecognizer.isEnabled)
		#expect(navigationController.panRecognizer.isEnabled)
	}

	private func makeNavigationController() -> UINavigationController {
		let navigationController = UINavigationController()
		navigationController.setViewControllers(
			[UIViewController(), UIViewController()],
			animated: false,
		)
		navigationController.loadViewIfNeeded()
		return navigationController
	}
}
#endif

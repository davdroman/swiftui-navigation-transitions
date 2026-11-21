#if !os(tvOS)
import Testing
import UIKit
@testable import UIKitNavigationTransitions

extension WindowTests {
	/// When the library's pop gestures can begin.
	@MainActor
	struct GestureRecognizerDelegateTests {
		@Test
		func `pop gestures begin only above the root`() {
			let navigationController = UINavigationController(rootViewController: UIViewController())
			let sut = NavigationGestureRecognizerDelegate(controller: navigationController)

			#expect(!sut.gestureRecognizerShouldBegin(UIPanGestureRecognizer()))

			navigationController.pushViewController(UIViewController(), animated: false)
			#expect(sut.gestureRecognizerShouldBegin(UIPanGestureRecognizer()))
		}

		@Test
		func `pop gestures don't begin while presenting`() async throws {
			let navigationController = UINavigationController()
			navigationController.setViewControllers([UIViewController(), UIViewController()], animated: false)
			let sut = NavigationGestureRecognizerDelegate(controller: navigationController)
			let host = try await TestWindow(rootViewController: navigationController)
			defer { host.restore() }

			navigationController.present(UIViewController(), animated: false)

			#expect(navigationController.presentedViewController != nil)
			#expect(!sut.gestureRecognizerShouldBegin(UIPanGestureRecognizer()))

			await withCheckedContinuation { continuation in
				navigationController.dismiss(animated: false) { continuation.resume() }
			}
			try await waitUntil { navigationController.presentedViewController == nil }
		}
	}
}
#endif

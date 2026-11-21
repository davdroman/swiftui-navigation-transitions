import SwiftUI
import SwiftUINavigationTransitions
import Testing
@testable import UIKitNavigationTransitions

extension WindowTests {
	@MainActor
	struct CustomNavigationTransitionModifierTests {
		@Test
		func `modifier installs the transition on the enclosing navigation stack`() async throws {
			let navigationController = try await withNavigationController {
				NavigationStack {
					Text("Root")
						.customNavigationTransition(.slide)
				}
			}

			let delegate = try #require(navigationController.customDelegate)
			#expect(animatesCustomTransition(navigationController, delegate))
			#expect(navigationController.delegate === delegate)
		}

		@Test
		func `modifier on the navigation stack installs the transition`() async throws {
			let navigationController = try await withNavigationController {
				NavigationStack {
					Text("Root")
				}
				.customNavigationTransition(.default)
			}

			let delegate = try #require(navigationController.customDelegate)
			#expect(!animatesCustomTransition(navigationController, delegate))
		}

		#if !os(tvOS) && !os(visionOS)
		@Test
		func `modifier applies the interactivity`() async throws {
			let navigationController = try await withNavigationController {
				NavigationStack {
					Text("Root")
						.customNavigationTransition(.slide, interactivity: .contentPan)
				}
			}

			#expect(navigationController.panRecognizer.isEnabled)
			#expect(!navigationController.edgePanRecognizer.isEnabled)
		}
		#endif

		@available(*, deprecated)
		@Test
		func `deprecated modifier installs the transition`() async throws {
			let navigationController = try await withNavigationController {
				NavigationStack {
					Text("Root")
						.navigationTransition(.slide)
				}
			}

			let delegate = try #require(navigationController.customDelegate)
			#expect(animatesCustomTransition(navigationController, delegate))
		}

		private func withNavigationController(
			@ViewBuilder _ content: () -> some View,
		) async throws -> UINavigationController {
			let hostingController = UIHostingController(rootView: content())
			let host = try await TestWindow(rootViewController: hostingController)
			defer { host.restore() }
			return try await waitUntilValue {
				navigationController(in: hostingController).flatMap { $0.customDelegate != nil ? $0 : nil }
			}
		}

		/// Whether pushing runs the library's animator rather than the system transition.
		private func animatesCustomTransition(
			_ navigationController: UINavigationController,
			_ delegate: NavigationTransitionDelegate,
		) -> Bool {
			delegate.navigationController(
				navigationController,
				animationControllerFor: .push,
				from: UIViewController(),
				to: UIViewController(),
			) != nil
		}

		private func navigationController(in viewController: UIViewController) -> UINavigationController? {
			if let navigationController = viewController as? UINavigationController {
				return navigationController
			}
			return viewController.children.lazy.compactMap { navigationController(in: $0) }.first
		}
	}
}

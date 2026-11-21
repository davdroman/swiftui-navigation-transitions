import Testing
import UIKit
@testable import UIKitNavigationTransitions

@MainActor
struct SetNavigationTransitionTests {
	@Test
	func `setting a transition again updates the installed delegate`() throws {
		let navigationController = UINavigationController()

		navigationController.setNavigationTransition(.slide)
		let delegate = try #require(navigationController.customDelegate)
		navigationController.setNavigationTransition(.default)

		#expect(navigationController.customDelegate === delegate)
		#expect(navigationController.delegate === delegate)
		#expect(!animatesCustomTransition(navigationController))
	}

	@Test
	func `the navigation controller's own delegate keeps receiving appearance callbacks`() {
		let navigationController = UINavigationController()
		let ownDelegate = RecordingDelegate()
		navigationController.delegate = ownDelegate

		navigationController.setNavigationTransition(.slide)
		navigationController.setNavigationTransition(.fade(.cross))
		navigationController.delegate?.navigationController?(
			navigationController,
			didShow: UIViewController(),
			animated: false,
		)

		#expect(ownDelegate.calls == ["didShow"])
	}

	private func animatesCustomTransition(_ navigationController: UINavigationController) -> Bool {
		navigationController.delegate?.navigationController?(
			navigationController,
			animationControllerFor: .push,
			from: UIViewController(),
			to: UIViewController(),
		) != nil
	}
}

extension WindowTests {
	/// Navigation methods animate exactly when the transition has an animation, whatever the caller asks for.
	@MainActor
	struct NavigationAnimationTests {
		@Test(arguments: [false, true])
		func `pushing animates when the transition has an animation`(hasAnimation: Bool) async throws {
			try await expectAnimation(hasAnimation, startingWith: 1) { navigationController in
				navigationController.pushViewController(UIViewController(), animated: !hasAnimation)
			}
		}

		@Test(arguments: [false, true])
		func `popping animates when the transition has an animation`(hasAnimation: Bool) async throws {
			try await expectAnimation(hasAnimation, startingWith: 2) { navigationController in
				navigationController.popViewController(animated: !hasAnimation)
			}
		}

		@Test(arguments: [false, true])
		func `popping to a view controller animates when the transition has an animation`(
			hasAnimation: Bool,
		) async throws {
			try await expectAnimation(hasAnimation, startingWith: 3) { navigationController in
				navigationController.popToViewController(navigationController.viewControllers[0], animated: !hasAnimation)
			}
		}

		@Test(arguments: [false, true])
		func `popping to the root animates when the transition has an animation`(hasAnimation: Bool) async throws {
			try await expectAnimation(hasAnimation, startingWith: 3) { navigationController in
				navigationController.popToRootViewController(animated: !hasAnimation)
			}
		}

		@Test(arguments: [false, true])
		func `setting view controllers animates when the transition has an animation`(
			hasAnimation: Bool,
		) async throws {
			try await expectAnimation(hasAnimation, startingWith: 1) { navigationController in
				navigationController.setViewControllers(
					navigationController.viewControllers + [UIViewController()],
					animated: !hasAnimation,
				)
			}
		}

		private func expectAnimation(
			_ hasAnimation: Bool,
			startingWith count: Int,
			_ navigate: (UINavigationController) -> Void,
			sourceLocation: SourceLocation = #_sourceLocation,
		) async throws {
			let navigationController = UINavigationController()
			navigationController.setViewControllers((0..<count).map { _ in UIViewController() }, animated: false)
			navigationController.setNavigationTransition(hasAnimation ? .slide : .slide.animation(nil))
			let host = try await TestWindow(rootViewController: navigationController)
			defer { host.restore() }

			navigate(navigationController)

			#expect(
				(navigationController.transitionCoordinator?.isAnimated ?? false) == hasAnimation,
				sourceLocation: sourceLocation,
			)
			try await waitUntil { navigationController.transitionCoordinator == nil }
		}
	}
}

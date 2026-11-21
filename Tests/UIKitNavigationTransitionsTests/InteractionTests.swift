#if !os(tvOS) && !os(visionOS)
import Testing
import UIKit
import UIKit.UIGestureRecognizerSubclass
@testable import UIKitNavigationTransitions

extension WindowTests {
	/// How a pan gesture drives an interactive pop.
	@MainActor
	struct InteractionTests {
		@Test(arguments: [
			// A fast enough swipe pops however far it went.
			(progress: 0.1, velocity: 700.0, finishes: true, completionSpeed: 0.99),
			(progress: 0.1, velocity: 600.0, finishes: false, completionSpeed: 1.0),
			// Past a fifth of the width, a pop finishes unless it's being swiped back.
			(progress: 0.3, velocity: -100.0, finishes: true, completionSpeed: 0.99),
			(progress: 0.3, velocity: -300.0, finishes: false, completionSpeed: 1.0),
			// Finishing speeds up with the swipe, up to a limit.
			(progress: 0.5, velocity: 1200.0, finishes: true, completionSpeed: 1.5),
			(progress: 0.5, velocity: 2000.0, finishes: true, completionSpeed: 2.25),
		])
		func `ending a pan finishes or cancels the pop`(
			progress: Double,
			velocity: Double,
			finishes: Bool,
			completionSpeed: Double,
		) async throws {
			let navigationController = makeNavigationController()
			let host = try await TestWindow(rootViewController: navigationController)
			defer { host.restore() }
			let delegate = try #require(navigationController.customDelegate)
			let pan = FakePanGestureRecognizer(view: navigationController.view)
			let width = navigationController.view.bounds.width

			pan.send(.began, translation: 0, to: navigationController)
			let interaction = try #require(delegate.interactionController)
			pan.send(.changed, translation: progress * width, to: navigationController)
			pan.send(.ended, translation: progress * width, velocity: velocity, to: navigationController)

			#expect(delegate.interactionController == nil)
			#expect(abs(interaction.completionSpeed - completionSpeed) < 0.000001)
			try await waitUntil { navigationController.transitionCoordinator == nil }
			#expect(navigationController.viewControllers.count == (finishes ? 1 : 2))
		}

		@Test(arguments: [UIGestureRecognizer.State.failed, .cancelled])
		func `a failed or cancelled pan cancels the pop`(state: UIGestureRecognizer.State) async throws {
			let navigationController = makeNavigationController()
			let host = try await TestWindow(rootViewController: navigationController)
			defer { host.restore() }
			let delegate = try #require(navigationController.customDelegate)
			let pan = FakePanGestureRecognizer(view: navigationController.view)

			pan.send(.began, translation: 0, to: navigationController)
			pan.send(.changed, translation: navigationController.view.bounds.width / 2, to: navigationController)
			pan.send(state, translation: navigationController.view.bounds.width / 2, to: navigationController)

			#expect(delegate.interactionController == nil)
			try await waitUntil { navigationController.transitionCoordinator == nil }
			#expect(navigationController.viewControllers.count == 2)
		}

		@Test
		func `a pan without a view drops the interaction`() throws {
			let navigationController = makeNavigationController()
			let delegate = try #require(navigationController.customDelegate)
			delegate.interactionController = UIPercentDrivenInteractiveTransition()

			FakePanGestureRecognizer(view: nil).send(.began, translation: 0, to: navigationController)

			#expect(delegate.interactionController == nil)
			#expect(navigationController.viewControllers.count == 2)
		}

		@Test
		func `a pan does nothing without a custom transition`() {
			let navigationController = UINavigationController()
			navigationController.setViewControllers([UIViewController(), UIViewController()], animated: false)

			FakePanGestureRecognizer(view: navigationController.view)
				.send(.began, translation: 0, to: navigationController)

			#expect(navigationController.viewControllers.count == 2)
		}

		private func makeNavigationController() -> UINavigationController {
			let navigationController = UINavigationController()
			navigationController.setViewControllers([UIViewController(), UIViewController()], animated: false)
			navigationController.setNavigationTransition(.slide, interactivity: .contentPan)
			return navigationController
		}
	}
}

/// A pan gesture recognizer whose state, translation, and velocity are set by the test.
@MainActor
private final class FakePanGestureRecognizer: UIPanGestureRecognizer {
	private let fakeView: UIView?
	private var fakeTranslation: CGFloat = 0
	private var fakeVelocity: CGFloat = 0
	private var fakeState: UIGestureRecognizer.State = .possible

	init(view: UIView?) {
		self.fakeView = view
		super.init(target: nil, action: nil)
	}

	override var view: UIView? { fakeView }

	override var state: UIGestureRecognizer.State {
		get { fakeState }
		set { fakeState = newValue }
	}

	override func translation(in view: UIView?) -> CGPoint {
		CGPoint(x: fakeTranslation, y: 0)
	}

	override func velocity(in view: UIView?) -> CGPoint {
		CGPoint(x: fakeVelocity, y: 0)
	}

	func send(
		_ state: UIGestureRecognizer.State,
		translation: CGFloat,
		velocity: CGFloat = 0,
		to navigationController: UINavigationController,
	) {
		fakeState = state
		fakeTranslation = translation
		fakeVelocity = velocity
		navigationController.handleInteraction(self)
	}
}
#endif

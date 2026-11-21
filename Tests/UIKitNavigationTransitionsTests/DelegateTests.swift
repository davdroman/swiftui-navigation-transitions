import Testing
import UIKit
@testable import UIKitNavigationTransitions

@MainActor
struct DelegateTests {
	let navigationController = UINavigationController()
	let from = UIViewController()
	let to = UIViewController()

	@Test
	func `custom transitions animate pushes and pops`() throws {
		let sut = NavigationTransitionDelegate(transition: .slide, baseDelegate: nil)

		let push = try #require(animationController(sut, for: .push) as? NavigationTransitionAnimatorProvider)
		let pop = try #require(animationController(sut, for: .pop) as? NavigationTransitionAnimatorProvider)

		#expect(push.operation == .push)
		#expect(pop.operation == .pop)
	}

	@Test
	func `the system animates the default transition, transitions without an animation, and other operations`() {
		#expect(animationController(NavigationTransitionDelegate(transition: .default, baseDelegate: nil), for: .push) ==
			nil)
		#expect(animationController(
			NavigationTransitionDelegate(transition: .slide.animation(nil), baseDelegate: nil),
			for: .push,
		) == nil)
		#expect(animationController(NavigationTransitionDelegate(transition: .slide, baseDelegate: nil), for: .none) == nil)
	}

	@Test
	func `custom transitions are driven by the current interaction`() {
		let sut = NavigationTransitionDelegate(transition: .slide, baseDelegate: nil)
		let animationController = NavigationTransitionAnimatorProvider(
			transition: .slide,
			animation: .default,
			operation: .pop,
		)

		#expect(sut.navigationController(navigationController, interactionControllerFor: animationController) == nil)

		let interaction = UIPercentDrivenInteractiveTransition()
		sut.interactionController = interaction
		#expect(sut
			.navigationController(navigationController, interactionControllerFor: animationController) === interaction)

		sut.transition = .default
		#expect(sut.navigationController(navigationController, interactionControllerFor: animationController) == nil)
	}

	@Test
	func `appearance callbacks reach the base delegate`() {
		let baseDelegate = RecordingDelegate()
		let sut = NavigationTransitionDelegate(transition: .slide, baseDelegate: baseDelegate)

		sut.navigationController(navigationController, willShow: to, animated: true)
		sut.navigationController(navigationController, didShow: to, animated: false)

		#expect(baseDelegate.calls == ["willShow animated", "didShow"])
	}

	@Test
	func `the base delegate isn't retained`() {
		var baseDelegate: RecordingDelegate? = RecordingDelegate()
		weak let weakBaseDelegate = baseDelegate
		let sut = NavigationTransitionDelegate(transition: .slide, baseDelegate: baseDelegate)

		baseDelegate = nil

		#expect(weakBaseDelegate == nil)
		sut.navigationController(navigationController, didShow: to, animated: false)
	}

	private func animationController(
		_ delegate: NavigationTransitionDelegate,
		for operation: UINavigationController.Operation,
	) -> (any UIViewControllerAnimatedTransitioning)? {
		delegate.navigationController(navigationController, animationControllerFor: operation, from: from, to: to)
	}
}

@MainActor
final class RecordingDelegate: NSObject, UINavigationControllerDelegate {
	private(set) var calls: [String] = []

	func navigationController(
		_ navigationController: UINavigationController,
		willShow viewController: UIViewController,
		animated: Bool,
	) {
		calls.append(animated ? "willShow animated" : "willShow")
	}

	func navigationController(
		_ navigationController: UINavigationController,
		didShow viewController: UIViewController,
		animated: Bool,
	) {
		calls.append(animated ? "didShow animated" : "didShow")
	}
}

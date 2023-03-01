@_spi(package) import Animation
@_spi(package) import Animator
@_spi(package) import NavigationTransition
import UIKit

final class NavigationTransitionDelegate: NSObject, UINavigationControllerDelegate {
	var transition: AnyNavigationTransition
	private weak var baseDelegate: UINavigationControllerDelegate?
	var interactionController: UIPercentDrivenInteractiveTransition?
	private var initialAreAnimationsEnabled = UIView.areAnimationsEnabled

	init(transition: AnyNavigationTransition, baseDelegate: UINavigationControllerDelegate?) {
		self.transition = transition
		self.baseDelegate = baseDelegate
	}

	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		initialAreAnimationsEnabled = UIView.areAnimationsEnabled
		UIView.setAnimationsEnabled(transition.animation != nil)
		baseDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
	}

	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		baseDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
		UIView.setAnimationsEnabled(initialAreAnimationsEnabled)
	}

	func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		if !transition.isDefault {
			return interactionController
		} else {
			return nil
		}
	}

	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if
			!transition.isDefault,
			let animation = transition.animation,
			let operation = NavigationTransitionOperation(operation)
		{
			return NavigationTransitionAnimatorProvider(
				transition: transition,
				animation: animation,
				operation: operation
			)
		} else {
			return nil
		}
	}
}

final class NavigationTransitionAnimatorProvider: NSObject, UIViewControllerAnimatedTransitioning {
	let transition: AnyNavigationTransition
	let animation: Animation
	let operation: NavigationTransitionOperation

	init(transition: AnyNavigationTransition, animation: Animation, operation: NavigationTransitionOperation) {
		self.transition = transition
		self.animation = animation
		self.operation = operation
	}

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		animation.duration
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		transitionAnimator(for: transitionContext).startAnimation()
	}

	func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
		transitionAnimator(for: transitionContext)
	}

	func animationEnded(_ transitionCompleted: Bool) {
		cachedAnimators.removeAll(keepingCapacity: true)
	}

	private var cachedAnimators: [ObjectIdentifier: UIViewPropertyAnimator] = .init(minimumCapacity: 1)

	private func transitionAnimator(for transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
		if let cached = cachedAnimators[ObjectIdentifier(transitionContext)] {
			return cached
		}
		let animator = UIViewPropertyAnimator(
			duration: transitionDuration(using: transitionContext),
			timingParameters: animation.timingParameters
		)
		cachedAnimators[ObjectIdentifier(transitionContext)] = animator

		switch transition.handler {
		case .transient(let handler):
			if let (fromView, toView) = transientViews(for: handler, animator: animator, context: transitionContext) {
				fromView.setUIViewProperties(to: \.initial)
				animator.addAnimations { fromView.setUIViewProperties(to: \.animation) }
				animator.addCompletion { _ in fromView.setUIViewProperties(to: \.completion) }

				toView.setUIViewProperties(to: \.initial)
				animator.addAnimations { toView.setUIViewProperties(to: \.animation) }
				animator.addCompletion { _ in toView.setUIViewProperties(to: \.completion) }
			}
		case .primitive(let handler):
			handler(animator, operation, transitionContext)
		}

		animator.addCompletion { _ in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}

		return animator
	}

	private func transientViews(
		for handler: AnyNavigationTransition.TransientHandler,
		animator: Animator,
		context: UIViewControllerContextTransitioning
	) -> (fromView: AnimatorTransientView, toView: AnimatorTransientView)? {
		guard
			let fromUIView = context.view(forKey: .from),
			let toUIView = context.view(forKey: .to)
		else {
			return nil
		}

		let fromView = AnimatorTransientView(fromUIView)
		let toView = AnimatorTransientView(toUIView)

		let container = context.containerView
		fromUIView.removeFromSuperview()
		container.addSubview(fromUIView)
		switch operation {
		case .push:
			container.insertSubview(toUIView, aboveSubview: fromUIView)
		case .pop:
			container.insertSubview(toUIView, belowSubview: fromUIView)
		}

		animator.addCompletion { [weak container, weak fromUIView, weak toUIView] _ in
			guard
				let container = container,
				let fromUIView = fromUIView,
				let toUIView = toUIView
			else {
				return
			}
			for subview in container.subviews {
				subview.removeFromSuperview()
			}
			if context.transitionWasCancelled {
				container.addSubview(fromUIView)
			} else {
				container.addSubview(toUIView)
			}
		}

		handler(fromView, toView, operation, container)

		return (fromView: fromView, toView: toView)
	}
}

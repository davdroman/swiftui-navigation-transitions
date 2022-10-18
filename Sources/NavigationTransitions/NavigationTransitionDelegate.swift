@_spi(package) import Animation
@_spi(package) import Animator
@_spi(package) import NavigationTransition
import UIKit

final class NavigationTransitionDelegate: NSObject, UINavigationControllerDelegate {
    let transition: NavigationTransition
    weak var baseDelegate: UINavigationControllerDelegate?
    var interactionController: UIPercentDrivenInteractiveTransition?

    init(transition: NavigationTransition, baseDelegate: UINavigationControllerDelegate?) {
        self.transition = transition
        self.baseDelegate = baseDelegate
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        baseDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        baseDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let operation = NavigationTransition.Operation(operation) {
            return NavigationTransitionAnimatorProvider(transition: transition, operation: operation)
        } else {
            return nil
        }
    }
}

final class NavigationTransitionAnimatorProvider: NSObject, UIViewControllerAnimatedTransitioning {
    let transition: NavigationTransition
    let operation: NavigationTransition.Operation

    init(transition: NavigationTransition, operation: NavigationTransition.Operation) {
        self.transition = transition
        self.operation = operation
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transition.animation.duration
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
            timingParameters: transition.animation.timingParameters
        )
        let operation = self.operation
        let context = NavigationTransition._Context(uiKitContext: transitionContext)

        transition.prepare(animator, for: operation, in: context)

        if let (fromView, toView) = context.transientViews {
            fromView.setUIViewProperties(to: \.initial)
            animator.addAnimations { fromView.setUIViewProperties(to: \.animation) }
            animator.addCompletion { _ in fromView.setUIViewProperties(to: \.completion) }

            toView.setUIViewProperties(to: \.initial)
            animator.addAnimations { toView.setUIViewProperties(to: \.animation) }
            animator.addCompletion { _ in toView.setUIViewProperties(to: \.completion) }
        }
        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        cachedAnimators[ObjectIdentifier(transitionContext)] = animator
        return animator
    }
}

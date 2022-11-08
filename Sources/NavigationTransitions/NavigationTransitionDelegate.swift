@_spi(package) import Animation
@_spi(package) import Animator
@_spi(package) import NavigationTransition
import UIKit

final class NavigationTransitionDelegate: NSObject, UINavigationControllerDelegate {
    let transition: AnyNavigationTransition
    weak var baseDelegate: UINavigationControllerDelegate?
    var interactionController: UIPercentDrivenInteractiveTransition?

    init(transition: AnyNavigationTransition, baseDelegate: UINavigationControllerDelegate?) {
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
        if let operation = NavigationTransitionOperation(operation) {
            return NavigationTransitionAnimatorProvider(transition: transition, operation: operation)
        } else {
            return nil
        }
    }
}

final class NavigationTransitionAnimatorProvider: NSObject, UIViewControllerAnimatedTransitioning {
    let transition: AnyNavigationTransition
    let operation: NavigationTransitionOperation

    init(transition: AnyNavigationTransition, operation: NavigationTransitionOperation) {
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

        if let (fromView, toView) = transientViews(for: transition, animator: animator, context: transitionContext) {
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

    private func transientViews(
        for transition: AnyNavigationTransition,
        animator: Animator,
        context: UIViewControllerContextTransitioning
    ) -> (fromView: AnimatorTransientView, toView: AnimatorTransientView)? {
        guard
            let handler = transition.handler,
            let fromUIView = context.view(forKey: .from),
            let fromUIViewSnapshot = fromUIView.snapshotView(afterScreenUpdates: false),
            let toUIView = context.view(forKey: .to),
            let toUIViewSnapshot = toUIView.snapshotView(afterScreenUpdates: true)
        else {
            return nil
        }

        let fromView = AnimatorTransientView(fromUIViewSnapshot)
        let toView = AnimatorTransientView(toUIViewSnapshot)

        let container = context.containerView
        fromUIView.removeFromSuperview()
        container.addSubview(fromUIViewSnapshot)
        switch operation {
        case .push:
            container.insertSubview(toUIViewSnapshot, aboveSubview: fromUIViewSnapshot)
        case .pop:
            container.insertSubview(toUIViewSnapshot, belowSubview: fromUIViewSnapshot)
        }

        // this is a hack that uses a 0-sized container to ensure that
        // toView is added to the view hierarchy but not visible,
        // in order to have toViewSnapshot sized properly
        let invisibleContainer = UIView()
        invisibleContainer.clipsToBounds = true
        invisibleContainer.addSubview(fromUIView)
        invisibleContainer.addSubview(toUIView)
        container.addSubview(invisibleContainer)

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

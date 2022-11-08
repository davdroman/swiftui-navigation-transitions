import UIKit

//extension NavigationTransition {
//    /// Typealias for `UIViewControllerContextTransitioning`.
//    public typealias Context = UIViewControllerContextTransitioning
//    public typealias AnimatorHandler = (Animator, Operation, Context) -> Void
//
//    /// A fully customizable transition that hands over a closure with the animator object used for the transition.
//    ///
//    /// - Parameters:
//    ///   - Animator: The `Animator` object used for the transition. Attach animations or completion blocks to it.
//    ///   - Operation: The ``Operation``. Possible values are `push` or `pop`. It's recommended that you
//    ///   customize the behavior of your transition based on this parameter.
//    ///   - Context: The raw `UIViewControllerContextTransitioning` instance of the transition coordinator.
//    ///
//    /// - Warning: Usage of this initializer is highly discouraged unless you know what you're doing.
//    /// Use ``custom(withTransientViews:)`` instead to ensure correct transition behavior.
//    public static func custom(withAnimator handler: @escaping AnimatorHandler) -> Self {
//        .init { animator, operation, context in
//            handler(animator, operation, context.uiKitContext)
//        }
//    }
//}
//
//extension NavigationTransition {
//    /// Typealias for `UIView`.
//    public typealias Container = UIView
//    public typealias TransientViewsHandler = (FromView, ToView, Operation, Container) -> Void
//
//    /// A customizable transition that hands over a closure with abstractly animatable view objects.
//    ///
//    /// - Parameters:
//    ///   - FromView: A `TransientView` abstracting over the origin view. Apply animations directly to this instance
//    ///   by modifying specific sub-properties of its `initial`, `animation`, or `completion` properties.
//    ///   - ToView: A `TransientView` abstracting over the destination view. Apply animations directly to this instance
//    ///   by modifying specific sub-properties of its `initial`, `animation`, or `completion` properties.
//    ///   - Operation: The ``Operation``. Possible values are `push` or `pop`. It's recommended that you
//    ///   customize the behavior of your transition based on this parameter.
//    ///   - Context: The raw `UIViewControllerContextTransitioning` instance of the transition coordinator.
//    public static func custom(withTransientViews handler: @escaping TransientViewsHandler) -> Self {
//        .init { _, fromView, toView, operation, context in
//            handler(fromView, toView, operation, context.containerView)
//        }
//    }
//}

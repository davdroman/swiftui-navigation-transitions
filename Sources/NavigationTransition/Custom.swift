import UIKit

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

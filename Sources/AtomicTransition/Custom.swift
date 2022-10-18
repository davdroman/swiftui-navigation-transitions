@_spi(package) import Animator
import UIKit

extension AtomicTransition {
    public typealias AnimatorHandler = (Animator, UIView, Operation, Context) -> Void

    /// A fully customizable transition that hands over a closure with the animator object used for the transition.
    ///
    /// - Parameters:
    ///   - Animator: The ``Animator`` object used for the transition. Attach animations or completion blocks to it.
    ///   - UIView: The raw `UIView` instance being animated.
    ///   - Operation: The ``Operation``. Possible values are `insertion` or `removal`. It's recommended that you
    ///   customize the behavior of your transition based on this parameter.
    ///   - Container: The raw `UIView` instance of the transition container.
    ///
    /// - Warning: Usage of this initializer is highly discouraged unless you know what you're doing.
    /// Use ``custom(withTransientView:)`` instead to ensure correct transition behavior.
    public static func custom(withAnimator handler: @escaping AnimatorHandler) -> Self {
        .init { animator, view, operation, context in
            handler(animator, view.uiView, operation, context)
        }
    }
}

extension AtomicTransition {
    /// Typealias for `UIView`.
    public typealias Container = UIView
    public typealias TransientViewHandler = (TransientView, Operation, Container) -> Void

    /// A customizable transition that hands over a closure with an abstracted animatable view object.
    ///
    /// - Parameters:
    ///   - TransientView: The ``TransientView`` instance being animated. Apply animations directly to this instance
    ///   by modifying specific sub-properties of its `initial`, `animation`, or `completion` properties.
    ///   - Operation: The ``Operation``. Possible values are `insertion` or `removal`. It's recommended that you
    ///   customize the behavior of your transition based on this parameter.
    ///   - Container: The raw `UIView` containing the transitioning views.
    public static func custom(withTransientView handler: @escaping TransientViewHandler) -> Self {
        .init { _, view, operation, context in
            handler(view, operation, context.containerView)
        }
    }
}

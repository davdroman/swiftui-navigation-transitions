@_spi(package) import Animator
import UIKit

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
        .init { view, operation, context in
            handler(view, operation, context.containerView)
        }
    }
}

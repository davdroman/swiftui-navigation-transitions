@_spi(package) import Animator
import class UIKit.UIView

extension AtomicTransition {
    public enum ZPosition {
        case front
        case back
    }

    /// A transition that shifts the view's z axis to the given value, regardless of insertion or removal.
    public static func zPosition(_ position: ZPosition) -> Self {
        .custom { view, _, container in
            switch position {
            case .front:
                container.bringSubviewToFront(view.uiView)
            case .back:
                container.sendSubviewToBack(view.uiView)
            }
        }
    }

    /// Equivalent to `zPosition(.front)`.
    @inlinable
    public static var bringToFront: Self {
        .zPosition(.front)
    }

    /// Equivalent to `zPosition(.back)`.
    @inlinable
    public static var sendToBack: Self {
        .zPosition(.back)
    }
}

public struct BringToFront: AtomicTransitionProtocol {
    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        container.bringSubviewToFront(view.uiView)
    }
}

extension BringToFront: Hashable {}

public struct SendToBack: AtomicTransitionProtocol {
    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        container.sendSubviewToBack(view.uiView)
    }
}

extension SendToBack: Hashable {}

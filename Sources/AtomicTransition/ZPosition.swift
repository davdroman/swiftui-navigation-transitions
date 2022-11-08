@_spi(package) import Animator
import class UIKit.UIView

/// A transition that brings the view to the front, regardless of insertion or removal.
public struct BringToFront: AtomicTransition {
    public init() {}

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        container.bringSubviewToFront(view.uiView)
    }
}

extension BringToFront: Hashable {}

/// A transition that sends the view to the back, regardless of insertion or removal.
public struct SendToBack: AtomicTransition {
    public init() {}

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        container.sendSubviewToBack(view.uiView)
    }
}

extension SendToBack: Hashable {}

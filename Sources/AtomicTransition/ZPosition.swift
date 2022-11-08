@_spi(package) import Animator
import class UIKit.UIView

/// A transition that brings the view to the front, regardless of insertion or removal.
public struct BringToFront: MirrorableAtomicTransition {
    public init() {}

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        container.bringSubviewToFront(view.uiView)
    }

    public func mirrored() -> SendToBack {
        SendToBack()
    }
}

extension BringToFront: Hashable {}

/// A transition that sends the view to the back, regardless of insertion or removal.
public struct SendToBack: MirrorableAtomicTransition {
    public init() {}

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        container.sendSubviewToBack(view.uiView)
    }

    public func mirrored() -> some AtomicTransition {
        BringToFront()
    }
}

extension SendToBack: Hashable {}

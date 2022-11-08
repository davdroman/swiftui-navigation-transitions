import class UIKit.UIView

/// A transition that returns the input view, unmodified, as the output view.
public struct Identity: AtomicTransition, MirrorableAtomicTransition {
    public init() {}

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        // NO-OP
    }

    @_transparent
    public func mirrored() -> Self {
        self
    }
}

extension Identity: Hashable {}

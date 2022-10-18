extension AtomicTransition {
    public enum ZPosition {
        case front
        case back
    }

    /// A transition that shifts the view's z axis to the given value, regardless of insertion or removal.
    public static func zPosition(_ position: ZPosition) -> Self {
        .custom { _, view, _, context in
            switch position {
            case .front:
                context.containerView.bringSubviewToFront(view)
            case .back:
                context.containerView.sendSubviewToBack(view)
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

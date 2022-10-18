extension NavigationTransition {
    public enum Fade {
        case `in`
        case out
        case cross
    }

    /// A transition that fades the pushed view in, fades the popped view out, or cross-fades both views.
    public static func fade(_ fade: Fade) -> Self {
        switch fade {
        case .in:
            return .asymmetric(
                push: .asymmetric(insertion: .opacity, removal: .identity),
                pop: .asymmetric(insertion: .identity, removal: .opacity)
            )
        case .out:
            return .asymmetric(
                push: .asymmetric(
                    insertion: .identity,
                    removal: .opacity.combined(with: .bringToFront)
                ),
                pop: .asymmetric(
                    insertion: .opacity.combined(with: .bringToFront),
                    removal: .identity
                )
            )
        case .cross:
            return .asymmetric(push: .opacity, pop: .opacity)
        }
    }
}

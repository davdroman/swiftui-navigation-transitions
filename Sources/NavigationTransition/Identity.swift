extension NavigationTransition {
    // For internal use only.
    static var identity: Self {
        .init { _, _, _ in }
    }
}

/// A transition that returns the input view, unmodified, as the output view.
public struct Identity: NavigationTransitionProtocol {
    public init() {}

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        // NO-OP
    }
}

extension Identity: Hashable {}

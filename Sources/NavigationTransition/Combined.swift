extension NavigationTransition {
    /// Combines this transition with another, returning a new transition that is the result of both transitions
    /// being applied.
    public func combined(with other: Self) -> Self {
        .init { animator, operation, context in
            self.prepare(animator, for: operation, in: context)
            other.prepare(animator, for: operation, in: context)
        }
    }
}

extension Collection where Element == NavigationTransition {
    /// Combines this collection of transitions, returning a new transition that is the result of all transitions
    /// being applied in original order.
    public func combined() -> NavigationTransition {
        reduce(.identity) { $0.combined(with: $1) }
    }
}

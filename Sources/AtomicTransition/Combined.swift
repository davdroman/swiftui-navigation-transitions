extension AtomicTransition {
    /// Combines this transition with another, returning a new transition that is the result of both transitions
    /// being applied.
    public func combined(with other: Self) -> Self {
        .init { view, operation, container in
            self.prepare(view, for: operation, in: container)
            other.prepare(view, for: operation, in: container)
        }
    }
}

extension Collection where Element == AtomicTransition {
    /// Combines this collection of transitions, returning a new transition that is the result of all transitions
    /// being applied in original order.
    public func combined() -> AtomicTransition {
        reduce(.identity) { $0.combined(with: $1) }
    }
}

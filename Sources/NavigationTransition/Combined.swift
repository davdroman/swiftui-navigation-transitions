//extension NavigationTransition {
//    /// Combines this transition with another, returning a new transition that is the result of both transitions
//    /// being applied.
//    public func combined(with other: Self) -> Self {
//        .init { animator, operation, context in
//            self.prepare(animator, for: operation, in: context)
//            other.prepare(animator, for: operation, in: context)
//        }
//    }
//}
//
//extension Collection where Element == NavigationTransition {
//    /// Combines this collection of transitions, returning a new transition that is the result of all transitions
//    /// being applied in original order.
//    public func combined() -> NavigationTransition {
//        reduce(.identity) { $0.combined(with: $1) }
//    }
//}

public struct Combined<TransitionA: NavigationTransitionProtocol, TransitionB: NavigationTransitionProtocol>: NavigationTransitionProtocol {
    private let transitionA: TransitionA
    private let transitionB: TransitionB

    init(_ transitionA: TransitionA, _ transitionB: TransitionB) {
        self.transitionA = transitionA
        self.transitionB = transitionB
    }

    public init(@NavigationTransitionBuilder transitions: () -> Self) {
        self = transitions()
    }

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        transitionA.transition(from: fromView, to: toView, for: operation, in: container)
        transitionB.transition(from: fromView, to: toView, for: operation, in: container)
    }
}

extension Combined: Equatable where TransitionA: Equatable, TransitionB: Equatable {}
extension Combined: Hashable where TransitionA: Hashable, TransitionB: Hashable {}

import class UIKit.UIView

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

public struct Combined<TransitionA: AtomicTransitionProtocol, TransitionB: AtomicTransitionProtocol>: AtomicTransitionProtocol {
    private let transitionA: TransitionA
    private let transitionB: TransitionB

    init(_ transitionA: TransitionA, _ transitionB: TransitionB) {
        self.transitionA = transitionA
        self.transitionB = transitionB
    }

    #if compiler(>=5.7)
    public init(@AtomicTransitionBuilder _ builder: () -> Self) {
        self = builder()
    }
    #else
    public init(@AtomicTransitionBuilder _ builder: () -> TransitionA) where TransitionB == Identity {
        self.init(builder(), Identity())
    }
    #endif

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        transitionA.transition(view, for: operation, in: container)
        transitionB.transition(view, for: operation, in: container)
    }
}

extension Combined: Equatable where TransitionA: Equatable, TransitionB: Equatable {}
extension Combined: Hashable where TransitionA: Hashable, TransitionB: Hashable {}

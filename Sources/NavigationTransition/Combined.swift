extension AnyNavigationTransition {
    /// Combines this transition with another, returning a new transition that is the result of both transitions
    /// being applied.
    public func combined(with other: Self) -> Self {
        guard let lhsHandler = self.handler, let rhsHandler = other.handler else {
            runtimeWarn(
                """
                Combining primitive and non-primitive transitions via 'combine(with:)' is not allowed.
                """
            )
            return self
        }
        return .init(
            Combined(Erased(handler: lhsHandler), Erased(handler: rhsHandler))
        )
    }
}

struct Erased: NavigationTransitionProtocol {
    private let handler: AnyNavigationTransition.Handler

    init(handler: @escaping AnyNavigationTransition.Handler) {
        self.handler = handler
    }

    func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        handler(fromView, toView, operation, container)
    }
}

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

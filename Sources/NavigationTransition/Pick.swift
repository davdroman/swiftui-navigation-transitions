import AtomicTransition

/// Used to define a transition that executes on push, and executes the mirrored version of said transition on pop.
public struct PickPush<Transition: NavigationTransition>: NavigationTransition {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
    }

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        switch operation {
        case .push:
            transition.transition(from: fromView, to: toView, for: operation, in: container)
        case .pop:
            return
        }
    }
}

extension PickPush: Equatable where Transition: Equatable {}
extension PickPush: Hashable where Transition: Hashable {}

/// Used to define a transition that executes on pop, and executes the mirrored version of said transition on push.
public struct PickPop<Transition: NavigationTransition>: NavigationTransition {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
    }

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        switch operation {
        case .push:
            return
        case .pop:
            transition.transition(from: fromView, to: toView, for: operation, in: container)
        }
    }
}

extension PickPop: Equatable where Transition: Equatable {}
extension PickPop: Hashable where Transition: Hashable {}

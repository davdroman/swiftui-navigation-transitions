import AtomicTransition

/// A composite transition that uses a different transition for insertion versus removal.
public struct Asymmetric<PushTransition: NavigationTransitionProtocol, PopTransition: NavigationTransitionProtocol>: NavigationTransitionProtocol {
    private let push: PushTransition
    private let pop: PopTransition

    public init(
        @AtomicTransitionBuilder push: () -> PushTransition,
        @AtomicTransitionBuilder pop: () -> PopTransition
    ) {
        self.push = push()
        self.pop = pop()
    }

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        switch operation {
        case .push:
            push.transition(from: fromView, to: toView, for: operation, in: container)
        case .pop:
            pop.transition(from: fromView, to: toView, for: operation, in: container)
        }
    }
}

extension Asymmetric: Equatable where PushTransition: Equatable, PopTransition: Equatable {}
extension Asymmetric: Hashable where PushTransition: Hashable, PopTransition: Hashable {}

/// A transition that executes only on insertion.
public struct OnPush<Transition: AtomicTransitionProtocol>: NavigationTransitionProtocol {
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
            transition.transition(fromView, for: .removal, in: container)
            transition.transition(toView, for: .insertion, in: container)
        case .pop:
            return
        }
    }
}

extension OnPush: Equatable where Transition: Equatable {}
extension OnPush: Hashable where Transition: Hashable {}

/// A transition that executes only on removal.
public struct OnPop<Transition: AtomicTransitionProtocol>: NavigationTransitionProtocol {
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
            transition.transition(fromView, for: .removal, in: container)
            transition.transition(toView, for: .insertion, in: container)
        }
    }
}

extension OnPop: Equatable where Transition: Equatable {}
extension OnPop: Hashable where Transition: Hashable {}

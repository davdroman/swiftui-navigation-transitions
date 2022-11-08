/// A transition that executes only on insertion.
public struct MirrorInsertion<Transition: AtomicTransition>: AtomicTransition {
    private let transition: Transition

    init(_ transition: Transition) {
        self.transition = transition
    }

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.init(transition())
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        switch operation {
        case .insertion:
            transition.transition(view, for: operation, in: container)
        case .removal:
            return
        }
    }
}

extension MirrorInsertion: MirrorableAtomicTransition where Transition: MirrorableAtomicTransition {
    public func mirrored() -> MirrorRemoval<Transition> {
        .init(transition)
    }
}

extension MirrorInsertion: Equatable where Transition: Equatable {}
extension MirrorInsertion: Hashable where Transition: Hashable {}

/// A transition that executes only on removal.
public struct MirrorRemoval<Transition: AtomicTransition>: AtomicTransition {
    private let transition: Transition

    init(_ transition: Transition) {
        self.transition = transition
    }

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.init(transition())
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        switch operation {
        case .insertion:
            return
        case .removal:
            transition.transition(view, for: operation, in: container)
        }
    }
}

extension MirrorRemoval: MirrorableAtomicTransition where Transition: MirrorableAtomicTransition {
    public func mirrored() -> MirrorInsertion<Transition> {
        .init(transition)
    }
}

extension MirrorRemoval: Equatable where Transition: Equatable {}
extension MirrorRemoval: Hashable where Transition: Hashable {}

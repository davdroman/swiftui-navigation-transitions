import AtomicTransition

/// Typealias for `MirrorPush`.
public typealias Mirror<Transition: MirrorableAtomicTransition> = MirrorPush<Transition>

public struct MirrorPush<Transition: MirrorableAtomicTransition>: NavigationTransition {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
    }

    public var body: some NavigationTransition {
        OnPush {
            transition
        }
        OnPop {
            transition.mirrored()
        }
    }
}

public struct MirrorPop<Transition: MirrorableAtomicTransition>: NavigationTransition {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
    }

    public var body: some NavigationTransition {
        OnPush {
            transition.mirrored()
        }
        OnPop {
            transition
        }
    }
}

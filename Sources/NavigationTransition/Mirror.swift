public import AtomicTransition

/// Used to define a transition that executes on push, and executes the mirrored version of said transition on pop.
public struct MirrorPush<Transition: MirrorableAtomicTransition>: NavigationTransitionProtocol {
	private let transition: Transition

	public init(@AtomicTransitionBuilder transition: () -> Transition) {
		self.transition = transition()
	}

	public var body: some NavigationTransitionProtocol {
		OnPush {
			transition
		}
		OnPop {
			transition.mirrored()
		}
	}
}

extension MirrorPush: Equatable where Transition: Equatable {}
extension MirrorPush: Hashable where Transition: Hashable {}

/// Used to define a transition that executes on pop, and executes the mirrored version of said transition on push.
public struct MirrorPop<Transition: MirrorableAtomicTransition>: NavigationTransitionProtocol {
	private let transition: Transition

	public init(@AtomicTransitionBuilder transition: () -> Transition) {
		self.transition = transition()
	}

	public var body: some NavigationTransitionProtocol {
		OnPush {
			transition.mirrored()
		}
		OnPop {
			transition
		}
	}
}

extension MirrorPop: Equatable where Transition: Equatable {}
extension MirrorPop: Hashable where Transition: Hashable {}

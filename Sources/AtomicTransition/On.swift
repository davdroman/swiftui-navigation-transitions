public import class UIKit.UIView

/// A transition that executes only on insertion.
public struct OnInsertion<Transition: AtomicTransition>: AtomicTransition {
	private let transition: Transition

	private init(_ transition: Transition) {
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

extension OnInsertion: MirrorableAtomicTransition where Transition: MirrorableAtomicTransition {
	public func mirrored() -> OnInsertion<Transition.Mirrored> {
		.init(transition.mirrored())
	}
}

extension OnInsertion: Equatable where Transition: Equatable {}
extension OnInsertion: Hashable where Transition: Hashable {}

/// A transition that executes only on removal.
public struct OnRemoval<Transition: AtomicTransition>: AtomicTransition {
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

extension OnRemoval: MirrorableAtomicTransition where Transition: MirrorableAtomicTransition {
	public func mirrored() -> OnRemoval<Transition.Mirrored> {
		.init(transition.mirrored())
	}
}

extension OnRemoval: Equatable where Transition: Equatable {}
extension OnRemoval: Hashable where Transition: Hashable {}

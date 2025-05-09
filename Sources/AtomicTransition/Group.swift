public import class UIKit.UIView

/// A composite transition that is the result of all the specified transitions being applied.
public struct Group<Transitions: AtomicTransition>: AtomicTransition {
	private let transitions: Transitions

	private init(_ transitions: Transitions) {
		self.transitions = transitions
	}

	public init(@AtomicTransitionBuilder _ transitions: () -> Transitions) {
		self.init(transitions())
	}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		transitions.transition(view, for: operation, in: container)
	}
}

extension Group: MirrorableAtomicTransition where Transitions: MirrorableAtomicTransition {
	public func mirrored() -> Group<Transitions.Mirrored> {
		.init(transitions.mirrored())
	}
}

extension Group: Equatable where Transitions: Equatable {}
extension Group: Hashable where Transitions: Hashable {}

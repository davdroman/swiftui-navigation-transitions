@resultBuilder
public enum AtomicTransitionBuilder {
	public static func buildBlock() -> Identity {
		Identity()
	}

	public static func buildPartialBlock<T1: AtomicTransition>(first: T1) -> T1 {
		first
	}

	public static func buildPartialBlock<T1: AtomicTransition, T2: AtomicTransition>(accumulated: T1, next: T2) -> Combined<T1, T2> {
		Combined(accumulated, next)
	}

	public static func buildOptional<T: AtomicTransition>(_ component: T?) -> _OptionalTransition<T> {
		if let component {
			_OptionalTransition(component)
		} else {
			_OptionalTransition(nil)
		}
	}

	public static func buildEither<TrueTransition: AtomicTransition, FalseTransition: AtomicTransition>(first component: TrueTransition) -> _ConditionalTransition<TrueTransition, FalseTransition> {
		_ConditionalTransition(trueTransition: component)
	}

	public static func buildEither<TrueTransition: AtomicTransition, FalseTransition: AtomicTransition>(second component: FalseTransition) -> _ConditionalTransition<TrueTransition, FalseTransition> {
		_ConditionalTransition(falseTransition: component)
	}
}

public struct _OptionalTransition<Transition: AtomicTransition>: AtomicTransition {
	private let transition: Transition?

	init(_ transition: Transition?) {
		self.transition = transition
	}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		transition?.transition(view, for: operation, in: container)
	}
}

extension _OptionalTransition: MirrorableAtomicTransition where Transition: MirrorableAtomicTransition {
	public func mirrored() -> _OptionalTransition<Transition.Mirrored> {
		.init(transition?.mirrored())
	}
}

extension _OptionalTransition: Equatable where Transition: Equatable {}
extension _OptionalTransition: Hashable where Transition: Hashable {}

public struct _ConditionalTransition<TrueTransition: AtomicTransition, FalseTransition: AtomicTransition>: AtomicTransition {
	private typealias Transition = _Either<TrueTransition, FalseTransition>
	private let transition: Transition

	init(trueTransition: TrueTransition) {
		self.transition = .left(trueTransition)
	}

	init(falseTransition: FalseTransition) {
		self.transition = .right(falseTransition)
	}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		switch transition {
		case .left(let trueTransition):
			trueTransition.transition(view, for: operation, in: container)
		case .right(let falseTransition):
			falseTransition.transition(view, for: operation, in: container)
		}
	}
}

extension _ConditionalTransition: MirrorableAtomicTransition where TrueTransition: MirrorableAtomicTransition, FalseTransition: MirrorableAtomicTransition {
	public func mirrored() -> _ConditionalTransition<TrueTransition.Mirrored, FalseTransition.Mirrored> {
		switch transition {
		case .left(let trueTransition):
			.init(trueTransition: trueTransition.mirrored())
		case .right(let falseTransition):
			.init(falseTransition: falseTransition.mirrored())
		}
	}
}

extension _ConditionalTransition: Equatable where TrueTransition: Equatable, FalseTransition: Equatable {}
extension _ConditionalTransition: Hashable where TrueTransition: Hashable, FalseTransition: Hashable {}

private enum _Either<Left, Right> {
	case left(Left)
	case right(Right)
}

extension _Either: Equatable where Left: Equatable, Right: Equatable {}
extension _Either: Hashable where Left: Hashable, Right: Hashable {}

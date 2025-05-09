@resultBuilder
public enum NavigationTransitionBuilder {
	public static func buildPartialBlock<T1: NavigationTransitionProtocol>(first: T1) -> T1 {
		first
	}

	public static func buildPartialBlock<T1: NavigationTransitionProtocol, T2: NavigationTransitionProtocol>(accumulated: T1, next: T2) -> Combined<T1, T2> {
		Combined(accumulated, next)
	}

	public static func buildOptional<T: NavigationTransitionProtocol>(_ component: T?) -> _OptionalTransition<T> {
		if let component {
			_OptionalTransition(component)
		} else {
			_OptionalTransition(nil)
		}
	}

	public static func buildEither<TrueTransition: NavigationTransitionProtocol, FalseTransition: NavigationTransitionProtocol>(first component: TrueTransition) -> _ConditionalTransition<TrueTransition, FalseTransition> {
		_ConditionalTransition(trueTransition: component)
	}

	public static func buildEither<TrueTransition: NavigationTransitionProtocol, FalseTransition: NavigationTransitionProtocol>(second component: FalseTransition) -> _ConditionalTransition<TrueTransition, FalseTransition> {
		_ConditionalTransition(falseTransition: component)
	}
}

public struct _OptionalTransition<Transition: NavigationTransitionProtocol>: NavigationTransitionProtocol {
	private let transition: Transition?

	init(_ transition: Transition?) {
		self.transition = transition
	}

	public func transition(
		from fromView: TransientView,
		to toView: TransientView,
		for operation: TransitionOperation,
		in container: Container
	) {
		transition?.transition(from: fromView, to: toView, for: operation, in: container)
	}
}

public struct _ConditionalTransition<TrueTransition: NavigationTransitionProtocol, FalseTransition: NavigationTransitionProtocol>: NavigationTransitionProtocol {
	private typealias Transition = _Either<TrueTransition, FalseTransition>
	private let transition: Transition

	init(trueTransition: TrueTransition) {
		self.transition = .left(trueTransition)
	}

	init(falseTransition: FalseTransition) {
		self.transition = .right(falseTransition)
	}

	public func transition(
		from fromView: TransientView,
		to toView: TransientView,
		for operation: TransitionOperation,
		in container: Container
	) {
		switch transition {
		case .left(let trueTransition):
			trueTransition.transition(from: fromView, to: toView, for: operation, in: container)
		case .right(let falseTransition):
			falseTransition.transition(from: fromView, to: toView, for: operation, in: container)
		}
	}
}

private enum _Either<Left, Right> {
	case left(Left)
	case right(Right)
}

extension _Either: Equatable where Left: Equatable, Right: Equatable {}
extension _Either: Hashable where Left: Hashable, Right: Hashable {}

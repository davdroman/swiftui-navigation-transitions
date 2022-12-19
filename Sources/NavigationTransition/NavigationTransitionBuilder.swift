@resultBuilder
public enum NavigationTransitionBuilder {
	#if compiler(>=5.7)
	public static func buildPartialBlock<T1: NavigationTransition>(first: T1) -> T1 {
		first
	}

	public static func buildPartialBlock<T1: NavigationTransition, T2: NavigationTransition>(accumulated: T1, next: T2) -> Combined<T1, T2> {
		Combined(accumulated, next)
	}
	#else
	public static func buildBlock<
		T1: NavigationTransition
	>(
		_ t1: T1
	) -> T1 {
		t1
	}

	public static func buildBlock<
		T1: NavigationTransition,
		T2: NavigationTransition
	>(
		_ t1: T1,
		_ t2: T2
	) -> Combined<T1, T2> {
		Combined(t1, t2)
	}

	public static func buildBlock<
		T1: NavigationTransition,
		T2: NavigationTransition,
		T3: NavigationTransition
	>(
		_ t1: T1,
		_ t2: T2,
		_ t3: T3
	) -> Combined<Combined<T1, T2>, T3> {
		Combined(Combined(t1, t2), t3)
	}

	public static func buildBlock<
		T1: NavigationTransition,
		T2: NavigationTransition,
		T3: NavigationTransition,
		T4: NavigationTransition
	>(
		_ t1: T1,
		_ t2: T2,
		_ t3: T3,
		_ t4: T4
	) -> Combined<Combined<Combined<T1, T2>, T3>, T4> {
		Combined(Combined(Combined(t1, t2), t3), t4)
	}

	public static func buildBlock<
		T1: NavigationTransition,
		T2: NavigationTransition,
		T3: NavigationTransition,
		T4: NavigationTransition,
		T5: NavigationTransition
	>(
		_ t1: T1,
		_ t2: T2,
		_ t3: T3,
		_ t4: T4,
		_ t5: T5
	) -> Combined<Combined<Combined<Combined<T1, T2>, T3>, T4>, T5> {
		Combined(Combined(Combined(Combined(t1, t2), t3), t4), t5)
	}

	public static func buildBlock<
		T1: NavigationTransition,
		T2: NavigationTransition,
		T3: NavigationTransition,
		T4: NavigationTransition,
		T5: NavigationTransition,
		T6: NavigationTransition
	>(
		_ t1: T1,
		_ t2: T2,
		_ t3: T3,
		_ t4: T4,
		_ t5: T5,
		_ t6: T6
	) -> Combined<Combined<Combined<Combined<Combined<T1, T2>, T3>, T4>, T5>, T6> {
		Combined(Combined(Combined(Combined(Combined(t1, t2), t3), t4), t5), t6)
	}

	public static func buildBlock<
		T1: NavigationTransition,
		T2: NavigationTransition,
		T3: NavigationTransition,
		T4: NavigationTransition,
		T5: NavigationTransition,
		T6: NavigationTransition,
		T7: NavigationTransition
	>(
		_ t1: T1,
		_ t2: T2,
		_ t3: T3,
		_ t4: T4,
		_ t5: T5,
		_ t6: T6,
		_ t7: T7
	) -> Combined<Combined<Combined<Combined<Combined<Combined<T1, T2>, T3>, T4>, T5>, T6>, T7> {
		Combined(Combined(Combined(Combined(Combined(Combined(t1, t2), t3), t4), t5), t6), t7)
	}
	#endif

	public static func buildOptional<T: NavigationTransition>(_ component: T?) -> _OptionalTransition<T> {
		if let component = component {
			return _OptionalTransition(component)
		} else {
			return _OptionalTransition(nil)
		}
	}

	public static func buildEither<TrueTransition: NavigationTransition, FalseTransition: NavigationTransition>(first component: TrueTransition) -> _ConditionalTransition<TrueTransition, FalseTransition> {
		_ConditionalTransition(trueTransition: component)
	}

	public static func buildEither<TrueTransition: NavigationTransition, FalseTransition: NavigationTransition>(second component: FalseTransition) -> _ConditionalTransition<TrueTransition, FalseTransition> {
		_ConditionalTransition(falseTransition: component)
	}
}

public struct _OptionalTransition<Transition: NavigationTransition>: NavigationTransition {
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

public struct _ConditionalTransition<TrueTransition: NavigationTransition, FalseTransition: NavigationTransition>: NavigationTransition {
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

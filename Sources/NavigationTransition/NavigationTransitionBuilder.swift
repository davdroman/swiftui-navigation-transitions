@resultBuilder
public struct NavigationTransitionBuilder {
    public static func buildBlock() -> Identity {
        Identity()
    }
    #if compiler(>=5.7)
    public static func buildPartialBlock<T1: NavigationTransitionProtocol>(first: T1) -> T1 {
        first
    }

    public static func buildPartialBlock<T1: NavigationTransitionProtocol, T2: NavigationTransitionProtocol>(accumulated: T1, next: T2) -> Combined<T1, T2> {
        Combined(accumulated, next)
    }
    #else
    public static func buildBlock<
        T1: NavigationTransitionProtocol
    >(
        _ t1: T1
    ) -> T1 {
        t1
    }

    public static func buildBlock<
        T1: NavigationTransitionProtocol,
        T2: NavigationTransitionProtocol
    >(
        _ t1: T1,
        _ t2: T2
    ) -> Combined<T1, T2> {
        Combined(t1, t2)
    }

    public static func buildBlock<
        T1: NavigationTransitionProtocol,
        T2: NavigationTransitionProtocol,
        T3: NavigationTransitionProtocol
    >(
        _ t1: T1,
        _ t2: T2,
        _ t3: T3
    ) -> Combined<Combined<T1, T2>, T3> {
        Combined(Combined(t1, t2), t3)
    }

    public static func buildBlock<
        T1: NavigationTransitionProtocol,
        T2: NavigationTransitionProtocol,
        T3: NavigationTransitionProtocol,
        T4: NavigationTransitionProtocol
    >(
        _ t1: T1,
        _ t2: T2,
        _ t3: T3,
        _ t4: T4
    ) -> Combined<Combined<Combined<T1, T2>, T3>, T4> {
        Combined(Combined(Combined(t1, t2), t3), t4)
    }

    public static func buildBlock<
        T1: NavigationTransitionProtocol,
        T2: NavigationTransitionProtocol,
        T3: NavigationTransitionProtocol,
        T4: NavigationTransitionProtocol,
        T5: NavigationTransitionProtocol
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
        T1: NavigationTransitionProtocol,
        T2: NavigationTransitionProtocol,
        T3: NavigationTransitionProtocol,
        T4: NavigationTransitionProtocol,
        T5: NavigationTransitionProtocol,
        T6: NavigationTransitionProtocol
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
        T1: NavigationTransitionProtocol,
        T2: NavigationTransitionProtocol,
        T3: NavigationTransitionProtocol,
        T4: NavigationTransitionProtocol,
        T5: NavigationTransitionProtocol,
        T6: NavigationTransitionProtocol,
        T7: NavigationTransitionProtocol
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

    public static func buildOptional<T: NavigationTransitionProtocol>(_ component: T?) -> _OptionalTransition<T> {
        if let component = component {
            return _OptionalTransition(component)
        } else {
            return _OptionalTransition(nil)
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
    private let trueTransition: TrueTransition?
    private let falseTransition: FalseTransition?

    init(trueTransition: TrueTransition) {
        self.trueTransition = trueTransition
        self.falseTransition = nil
    }

    init(falseTransition: FalseTransition) {
        self.trueTransition = nil
        self.falseTransition = falseTransition
    }

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        trueTransition?.transition(from: fromView, to: toView, for: operation, in: container)
        falseTransition?.transition(from: fromView, to: toView, for: operation, in: container)
    }
}

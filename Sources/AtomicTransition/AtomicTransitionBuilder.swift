@resultBuilder
public struct AtomicTransitionBuilder {
    public static func buildBlock() -> Identity {
        Identity()
    }
    #if compiler(>=5.7)
    public static func buildPartialBlock<T1: AtomicTransitionProtocol>(first: T1) -> T1 {
        first
    }

    public static func buildPartialBlock<T1: AtomicTransitionProtocol, T2: AtomicTransitionProtocol>(accumulated: T1, next: T2) -> Combined<T1, T2> {
        Combined(accumulated, next)
    }
    #else
    public static func buildBlock<
        T1: AtomicTransitionProtocol
    >(
        _ t1: T1
    ) -> T1 {
        t1
    }

    public static func buildBlock<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol
    >(
        _ t1: T1,
        _ t2: T2
    ) -> Combined<T1, T2> {
        Combined(t1, t2)
    }

    public static func buildBlock<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol
    >(
        _ t1: T1,
        _ t2: T2,
        _ t3: T3
    ) -> Combined<Combined<T1, T2>, T3> {
        Combined(Combined(t1, t2), t3)
    }

    public static func buildBlock<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol,
        T4: AtomicTransitionProtocol
    >(
        _ t1: T1,
        _ t2: T2,
        _ t3: T3,
        _ t4: T4
    ) -> Combined<Combined<Combined<T1, T2>, T3>, T4> {
        Combined(Combined(Combined(t1, t2), t3), t4)
    }

    public static func buildBlock<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol,
        T4: AtomicTransitionProtocol,
        T5: AtomicTransitionProtocol
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
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol,
        T4: AtomicTransitionProtocol,
        T5: AtomicTransitionProtocol,
        T6: AtomicTransitionProtocol
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
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol,
        T4: AtomicTransitionProtocol,
        T5: AtomicTransitionProtocol,
        T6: AtomicTransitionProtocol,
        T7: AtomicTransitionProtocol
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
}

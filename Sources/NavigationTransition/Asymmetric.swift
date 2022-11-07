@_spi(package) import AtomicTransition

extension NavigationTransition {
    /// Provides a composite transition that uses a different transition for push versus pop.
    public static func asymmetric(push: Self, pop: Self) -> Self {
        .init { animator, operation, context in
            switch operation {
            case .push:
                push.prepare(animator, for: operation, in: context)
            case .pop:
                pop.prepare(animator, for: operation, in: context)
            }
        }
    }
}

extension NavigationTransition {
    /// Provides a composite transition that uses a different transition for push versus pop.
    public static func asymmetric(push: AtomicTransition, pop: AtomicTransition) -> Self {
        .init { animator, fromView, toView, operation, context in
            switch operation {
            case .push:
                push.prepare(fromView, for: .removal, in: context)
                push.prepare(toView, for: .insertion, in: context)
            case .pop:
                pop.prepare(fromView, for: .removal, in: context)
                pop.prepare(toView, for: .insertion, in: context)
            }
        }
    }
}

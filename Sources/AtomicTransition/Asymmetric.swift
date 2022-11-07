import class UIKit.UIView

extension AtomicTransition {
    /// Provides a composite transition that uses a different transition for insertion versus removal.
    public static func asymmetric(insertion: Self, removal: Self) -> Self {
        .init { view, operation, container in
            switch operation {
            case .insertion:
                insertion.prepare(view, for: operation, in: container)
            case .removal:
                removal.prepare(view, for: operation, in: container)
            }
        }
    }
}

public struct Asymmetric<InsertionTransition: AtomicTransitionProtocol, RemovalTransition: AtomicTransitionProtocol>: AtomicTransitionProtocol {
    private let insertion: InsertionTransition
    private let removal: RemovalTransition

    init(insertion: InsertionTransition, removal: RemovalTransition) {
        self.insertion = insertion
        self.removal = removal
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        switch operation {
        case .insertion:
            insertion.transition(view, for: operation, in: container)
        case .removal:
            removal.transition(view, for: operation, in: container)
        }
    }
}

public struct OnInsertion<Transition: AtomicTransitionProtocol>: AtomicTransitionProtocol {
    private let transition: Transition

    init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
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

public struct OnRemoval<Transition: AtomicTransitionProtocol>: AtomicTransitionProtocol {
    private let transition: Transition

    init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
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

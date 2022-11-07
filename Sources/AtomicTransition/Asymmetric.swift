import class UIKit.UIView

extension AtomicTransition {
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

/// Provides a composite transition that uses a different transition for insertion versus removal.
public struct Asymmetric<InsertionTransition: AtomicTransitionProtocol, RemovalTransition: AtomicTransitionProtocol>: AtomicTransitionProtocol {
    private let insertion: InsertionTransition
    private let removal: RemovalTransition

    public init(
        @AtomicTransitionBuilder insertion: () -> InsertionTransition,
        @AtomicTransitionBuilder removal: () -> RemovalTransition
    ) {
        self.insertion = insertion()
        self.removal = removal()
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

extension Asymmetric: Equatable where InsertionTransition: Equatable, RemovalTransition: Equatable {}
extension Asymmetric: Hashable where InsertionTransition: Hashable, RemovalTransition: Hashable {}

/// Provides a transition that executes only on insertion.
public struct OnInsertion<Transition: AtomicTransitionProtocol>: AtomicTransitionProtocol {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
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

extension OnInsertion: Equatable where Transition: Equatable {}
extension OnInsertion: Hashable where Transition: Hashable {}

/// Provides a transition that executes only on removal.
public struct OnRemoval<Transition: AtomicTransitionProtocol>: AtomicTransitionProtocol {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
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

extension OnRemoval: Equatable where Transition: Equatable {}
extension OnRemoval: Hashable where Transition: Hashable {}

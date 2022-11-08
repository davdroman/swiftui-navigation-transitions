import class UIKit.UIView

/// A composite transition that uses a different transition for insertion versus removal.
public struct Asymmetric<InsertionTransition: AtomicTransition, RemovalTransition: AtomicTransition>: AtomicTransition {
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

/// A transition that executes only on insertion.
public struct OnInsertion<Transition: AtomicTransition>: AtomicTransition {
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

/// A transition that executes only on removal.
public struct OnRemoval<Transition: AtomicTransition>: AtomicTransition {
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

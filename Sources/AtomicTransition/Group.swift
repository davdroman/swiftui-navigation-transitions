import class UIKit.UIView

public struct Group<Transitions: AtomicTransitionProtocol>: AtomicTransitionProtocol {
    private let transitions: Transitions

    init(@AtomicTransitionBuilder _ transitions: () -> Transitions) {
        self.transitions = transitions()
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        transitions.transition(view, for: operation, in: container)
    }
}

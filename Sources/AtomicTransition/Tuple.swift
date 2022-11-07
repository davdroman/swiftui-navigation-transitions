import class Animator.AnimatorTransientView
import class UIKit.UIView

/// Inspired by `TupleView` in SwiftUI.
///
/// This type helps collect all transitions in `AtomicTransitionBuilder` and forward over their implementation
/// without losing type information.
public struct Tuple<T>: AtomicTransitionProtocol {
    var value: T

    init(_ value: T) {
        self.value = value
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        fatalError("Invalid AtomicTransition Tuple type \(type(of: self))")
    }
}

extension Tuple {
    public func transition(
        _ view: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) where T == () {
        // NO-OP
    }

    public func transition(
        _ view: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) where T: AtomicTransitionProtocol {
        value.transition(view, for: operation, in: container)
    }

    public func transition<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol
    >(
        _ view: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) where T == (T1, T2) {
        value.0.transition(view, for: operation, in: container)
        value.1.transition(view, for: operation, in: container)
    }

    public func transition<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol
    >(
        _ view: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) where T == (T1, T2, T3) {
        value.0.transition(view, for: operation, in: container)
        value.1.transition(view, for: operation, in: container)
        value.2.transition(view, for: operation, in: container)
    }

    public func transition<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol,
        T4: AtomicTransitionProtocol
    >(
        _ view: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) where T == (T1, T2, T3, T4) {
        value.0.transition(view, for: operation, in: container)
        value.1.transition(view, for: operation, in: container)
        value.2.transition(view, for: operation, in: container)
        value.3.transition(view, for: operation, in: container)
    }

    public func transition<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol,
        T4: AtomicTransitionProtocol,
        T5: AtomicTransitionProtocol
    >(
        _ view: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) where T == (T1, T2, T3, T4, T5) {
        value.0.transition(view, for: operation, in: container)
        value.1.transition(view, for: operation, in: container)
        value.2.transition(view, for: operation, in: container)
        value.3.transition(view, for: operation, in: container)
        value.4.transition(view, for: operation, in: container)
    }

    public func transition<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol,
        T4: AtomicTransitionProtocol,
        T5: AtomicTransitionProtocol,
        T6: AtomicTransitionProtocol
    >(
        _ view: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) where T == (T1, T2, T3, T4, T5, T6) {
        value.0.transition(view, for: operation, in: container)
        value.1.transition(view, for: operation, in: container)
        value.2.transition(view, for: operation, in: container)
        value.3.transition(view, for: operation, in: container)
        value.4.transition(view, for: operation, in: container)
        value.5.transition(view, for: operation, in: container)
    }

    public func transition<
        T1: AtomicTransitionProtocol,
        T2: AtomicTransitionProtocol,
        T3: AtomicTransitionProtocol,
        T4: AtomicTransitionProtocol,
        T5: AtomicTransitionProtocol,
        T6: AtomicTransitionProtocol,
        T7: AtomicTransitionProtocol
    >(
        _ view: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) where T == (T1, T2, T3, T4, T5, T6, T7) {
        value.0.transition(view, for: operation, in: container)
        value.1.transition(view, for: operation, in: container)
        value.2.transition(view, for: operation, in: container)
        value.3.transition(view, for: operation, in: container)
        value.4.transition(view, for: operation, in: container)
        value.5.transition(view, for: operation, in: container)
        value.6.transition(view, for: operation, in: container)
    }
}

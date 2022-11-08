import class Animator.AnimatorTransientView
import class UIKit.UIView
import protocol UIKit.UIViewControllerContextTransitioning

/// Represents an atomic transition which applies to a single view. It is the building block of `NavigationTransition`.
///
/// The API mirrors that of SwiftUI `AnyTransition`, striving for maximum familiarity. Like `AnyTransition`,
/// `AtomicTransition` is designed to handle both the insertion and the removal of a view, and is agnostic as to what
/// the overarching operation (push vs pop) is. This design allows great flexibility when defining fully-fledged
/// navigation transitions. In other words, a `NavigationTransition` is the aggregate of two or more `AtomicTransition`s.
public struct AtomicTransition {
    public enum Operation {
        case insertion
        case removal
    }

    /// Typealias for `AnimatorTransientView`.
    public typealias TransientView = AnimatorTransientView
    /// Typealias for `UIViewControllerContextTransitioning`.
    public typealias Context = UIViewControllerContextTransitioning

    typealias _Handler = (TransientView, Operation, Context) -> Void

    private var handler: _Handler

    init(handler: @escaping _Handler) {
        self.handler = handler
    }

    @_spi(package)public func prepare(_ view: TransientView, for operation: Operation, in context: Context) {
        self.handler(view, operation, context)
    }
}

/// Defines an atomic transition which applies to a single view. It is the core building block of
/// `NavigationTransition`.
///
/// Similarly to SwiftUI's `AnyTransition`, `AtomicTransition` is designed to handle both the insertion and the removal
/// of a view, and is agnostic as to what the overarching operation (push vs pop) is. This design allows great
/// composability when defining complex navigation transitions.
public protocol AtomicTransitionProtocol {
    /// Typealias for `AtomicTransitionOperation`.
    typealias TransitionOperation = AtomicTransitionOperation
    /// Typealias for `AnimatorTransientView`.
    typealias TransientView = AnimatorTransientView
    /// Typealias for `UIView`.
    typealias Container = UIView

    /// Set up your atomic transition within this function.
    ///
    /// - Parameters:
    ///   - view: The ``TransientView`` instance being animated. Apply animations directly to this instance
    ///   by modifying specific sub-properties of its `initial`, `animation`, or `completion` properties.
    ///   - operation: The ``TransitionOperation``. Possible values are `insertion` or `removal`.
    ///   It's recommended that you customize the behavior of your transition based on this parameter.
    ///   - container: The raw `UIView` containing the transitioning views.
    func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container)
}

public enum AtomicTransitionOperation {
    case insertion
    case removal
}

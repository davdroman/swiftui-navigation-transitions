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

public enum AtomicTransitionOperation {
    case insertion
    case removal
}

public protocol AtomicTransitionProtocol {
    typealias TransitionOperation = AtomicTransitionOperation
    typealias TransientView = AnimatorTransientView
    typealias Container = UIView

    func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container)
}

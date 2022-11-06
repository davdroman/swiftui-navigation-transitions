import Animator
import UIKit

public typealias _Animator = Animator

/// Represents an atomic transition which applies to a single view. It is the building block of `NavigationTransition`.
///
/// The API mirrors that of SwiftUI `AnyTransition`, striving for maximum familiarity. Like `AnyTransition`,
/// `AtomicTransition` is designed to handle both the insertion and the removal of a view, and is agnostic as to what
/// the overarching operation (push vs pop) is. This design allows great flexibility when defining fully-fledged
/// navigation transitions. In other words, a `NavigationTransition` is the aggregate of two or more `AtomicTransition`s.
public struct AtomicTransition {
    public typealias Animator = _Animator

    public enum Operation {
        case insertion
        case removal
    }

    /// Typealias for `AnimatorTransientView`.
    public typealias TransientView = AnimatorTransientView
    /// Typealias for `UIViewControllerContextTransitioning`.
    public typealias Context = UIViewControllerContextTransitioning

    @_spi(package)public typealias _Handler = (Animator, TransientView, Operation, Context) -> Void

    private var handler: _Handler

    init(handler: @escaping _Handler) {
        self.handler = handler
    }

    @_spi(package)public func prepare(_ animator: Animator, or view: TransientView, for operation: Operation, in context: Context) {
        self.handler(animator, view, operation, context)
    }
}

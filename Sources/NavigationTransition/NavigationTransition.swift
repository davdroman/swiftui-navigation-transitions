import UIKit

/// Defines a transition which applies to two views: an origin ("from") view and a destination ("to") view.
///
/// It is designed to handle both push and pop operations for a pair of views in a given navigation stack transition,
/// and is usually composed of smaller isolated transitions of type `AtomicTransition`, which act as building blocks.
///
/// Although the library ships with a set of predefined transitions (e.g. ``Slide``, one can also create
/// entirely new, fully customizable transitions by conforming to this protocol.
public protocol NavigationTransition {
    /// Typealias for `AnimatorTransientView`.
    typealias TransientView = AnimatorTransientView
    /// Typealias for `NavigationTransitionOperation`.
    typealias TransitionOperation = NavigationTransitionOperation
    /// Typealias for `UIView`.
    typealias Container = UIView

    // NB: for Xcode to favor autocompleting `var body: Body` over `var body: Never` we must use a type alias.
    associatedtype _Body

    /// A type representing the body of this transition.
    ///
    /// If you create a custom transition by implementing ``transition(from:to:for:in:)-211yh``, Swift
    /// infers this type to be `Never`.
    typealias Body = _Body

    /// Used to implement a custom navigation transition.
    ///
    /// - Parameters:
    ///   - fromView: A `TransientView` abstracting over the origin view. Apply animations directly to this instance
    ///   by modifying specific sub-properties of its `initial`, `animation`, or `completion` properties.
    ///   - toView: A `TransientView` abstracting over the destination view. Apply animations directly to this instance
    ///   by modifying specific sub-properties of its `initial`, `animation`, or `completion` properties.
    ///   - operation: The ``TransitionOperation``. Possible values are `push` or `pop`. It's recommended that you
    ///   customize the behavior of your transition based on this parameter.
    ///   - container: The raw `UIView` containing the transitioning views.
    func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    )

    /// The content of a navigation transition that is composed from other transitions.
    ///
    /// Implement this requirement when you want to combine the behavior of other transitions
    /// together.
    ///
    /// Do not invoke this property directly.
    ///
    /// - Important: If your transition implements the ``transition(from:to:for:in:)-22zdm`` method, it will take precedence
    ///   over this property, and only ``transition(from:to:for:in:)-22zdm`` will be called by the animator.
    @NavigationTransitionBuilder
    var body: Body { get }
}

extension NavigationTransition where Body: NavigationTransition {
    /// Invokes ``body``'s implementation of ``transition(from:to:for:in:)-211yh``.
    @inlinable
    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        self.body.transition(from: fromView, to: toView, for: operation, in: container)
    }
}

extension NavigationTransition where Body == Never {
    /// A non-existent body.
    ///
    /// > Warning: Do not invoke this property directly. It will trigger a fatal error at runtime.
    @_transparent
    public var body: Body {
        fatalError(
            """
            '\(Self.self)' has no body. …
            Do not access a transition's 'body' property directly, as it may not exist.
            """
        )
    }
}

public enum NavigationTransitionOperation: Hashable {
    case push
    case pop

    @_spi(package)public init?(_ operation: UINavigationController.Operation) {
        switch operation {
        case .push:
            self = .push
        case .pop:
            self = .pop
        case .none:
            return nil
        @unknown default:
            return nil
        }
    }
}

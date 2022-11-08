import Animation
@_spi(package) import Animator
import UIKit

public typealias _Animator = Animator

public struct AnyNavigationTransition {
    @_spi(package)public typealias Handler = ((AnimatorTransientView, AnimatorTransientView, NavigationTransitionOperation, UIView) -> Void)

    @_spi(package)public let type: Any.Type
    @_spi(package)public let handler: Handler?
//    @_spi(package)public let primitiveHandler: ()
    @_spi(package)public var animation: Animation = .default

    public init<T: NavigationTransitionProtocol>(_ transition: T) {
        self.type = Swift.type(of: transition)
        self.handler = transition.transition(from:to:for:in:)
    }
}

extension AnyNavigationTransition {
    /// Attaches an animation to this transition.
    public func animation(_ animation: Animation) -> Self {
        var copy = self
        copy.animation = animation
        return copy
    }
}

//public protocol PrimitiveNavigationTransitionProtocol {
//    /// Typealias for `NavigationTransitionOperation`.
//    typealias TransitionOperation = NavigationTransitionOperation
//    /// Typealias for `UIViewControllerContextTransitioning`.
//    typealias Context = UIViewControllerContextTransitioning
//
//    @_spi(package) func prepare(_ animator: Animator, for operation: TransitionOperation, in context: Context)
//}

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

/// Defines a transition which applies to two views: an origin ("from") view and a destination ("to") view.
///
/// It is designed to handle both push and pop operations for a pair of views in a given navigation stack transition,
/// and is usually composed of smaller isolated transitions of type `AtomicTransition`, which act as building blocks.
///
/// Although the library ships with a set of predefined transitions (e.g. ``slide(axis:)``, one can also create
/// entirely new, fully customizable transitions by conforming to this protocol.
public protocol NavigationTransitionProtocol {
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
    /// When you create a custom transition by implementing the ``body-swift.property-7foai``, Swift
    /// infers this type from the value returned.
    ///
    /// If you create a custom reducer by implementing the ``reduce(into:action:)-8yinq``, Swift
    /// infers this type to be `Never`.
    typealias Body = _Body

    /// Set up a custom navigation transition within this function.
    ///
    /// - Parameters:
    ///   - fromView: A `TransientView` abstracting over the origin view. Apply animations directly to this instance
    ///   by modifying specific sub-properties of its `initial`, `animation`, or `completion` properties.
    ///   - toView: A `TransientView` abstracting over the destination view. Apply animations directly to this instance
    ///   by modifying specific sub-properties of its `initial`, `animation`, or `completion` properties.
    ///   - operation: The ``Operation``. Possible values are `push` or `pop`. It's recommended that you
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
    /// - Important: If your transition implements the ``transition(from:to:for:in:)`` method, it will take precedence
    ///   over this property, and only ``transition(from:to:for:in:)`` will be called by the animator.
    @NavigationTransitionBuilder
    var body: Body { get }
}

extension NavigationTransitionProtocol where Body: NavigationTransitionProtocol {
    /// Invokes ``body``'s implementation of ``transition(from:to:for:in:)``.
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

extension NavigationTransitionProtocol where Body == Never {
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

import Animation
import UIKit

public struct AnyNavigationTransition {
    @_spi(package)public typealias Handler = (
        AnimatorTransientView,
        AnimatorTransientView,
        NavigationTransitionOperation,
        UIView
    ) -> Void

    @_spi(package)public typealias PrimitiveHandler = (
        Animator,
        NavigationTransitionOperation,
        UIViewControllerContextTransitioning
    ) -> Void

    @_spi(package)public let type: Any.Type
    @_spi(package)public let handler: Handler?
    @_spi(package)public let primitiveHandler: PrimitiveHandler?
    @_spi(package)public var animation: Animation = .default

    public init<T: NavigationTransition>(_ transition: T) {
        self.type = Swift.type(of: transition)
        self.handler = transition.transition(from:to:for:in:)
        self.primitiveHandler = nil
    }

    public init<T: PrimitiveNavigationTransition>(_ transition: T) {
        self.type = Swift.type(of: transition)
        self.handler = nil
        self.primitiveHandler = transition.transition(with:for:in:)
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

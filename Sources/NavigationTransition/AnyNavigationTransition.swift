import Animation
import UIKit

public struct AnyNavigationTransition {
	@_spi(package) public typealias TransientHandler = (
		AnimatorTransientView,
		AnimatorTransientView,
		NavigationTransitionOperation,
		UIView
	) -> Void

	@_spi(package) public typealias PrimitiveHandler = (
		Animator,
		NavigationTransitionOperation,
		UIViewControllerContextTransitioning
	) -> Void

	@_spi(package) public enum Handler {
		case transient(TransientHandler)
		case primitive(PrimitiveHandler)
	}

	@_spi(package) public let isDefault: Bool
	@_spi(package) public let handler: Handler
	@_spi(package) public var animation: Animation? = .default

	public init<T: NavigationTransition>(_ transition: T) {
		self.isDefault = false
		self.handler = .transient(transition.transition(from:to:for:in:))
	}

	public init<T: PrimitiveNavigationTransition>(_ transition: T) {
		self.isDefault = transition is Default
		self.handler = .primitive(transition.transition(with:for:in:))
	}
}

public typealias _Animation = Animation

extension AnyNavigationTransition {
	/// Typealias for `Animation`.
	public typealias Animation = _Animation

	/// Attaches an animation to this transition.
	public func animation(_ animation: Animation?) -> Self {
		var copy = self
		copy.animation = animation
		return copy
	}
}

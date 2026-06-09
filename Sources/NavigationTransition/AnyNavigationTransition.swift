public import Animation
package import UIKit

public struct AnyNavigationTransition {
	package typealias TransientHandler = @MainActor (
		AnimatorTransientView,
		AnimatorTransientView,
		NavigationTransitionOperation,
		UIView
	) -> Void

	package typealias PrimitiveHandler = @MainActor (
		any Animator,
		NavigationTransitionOperation,
		any UIViewControllerContextTransitioning
	) -> Void

	package enum Handler {
		case transient(TransientHandler)
		case primitive(PrimitiveHandler)
	}

	package let isDefault: Bool
	package let handler: Handler
	package var animation: Animation?

	@MainActor
	public init(_ transition: some NavigationTransitionProtocol) {
		self.isDefault = false
		self.handler = .transient(transition.transition(from:to:for:in:))
		self.animation = .default
	}

	@MainActor
	public init(_ transition: some PrimitiveNavigationTransition) {
		self.isDefault = transition is Default
		self.handler = .primitive(transition.transition(with:for:in:))
		self.animation = .default
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

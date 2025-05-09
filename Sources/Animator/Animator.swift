public import SwiftUI

/// Typealias for `Animator`. Useful for disambiguation.
public typealias _Animator = Animator

/// A protocol representing an abstract view animator, whose sole
/// responsibility is receiving animation and completion blocks
/// as a means to define end-to-end animations as the sum of said blocks.
///
/// Its interface is a subset of the interface of `UIViewImplicitlyAnimating`.
@objc public protocol Animator {
	/// Adds the specified animation block to the animator.
	///
	/// Use this method to add new animation blocks to the animator. The animations in the new block run alongside
	/// any previously configured animations.
	///
	/// If the animation block modifies a property that’s being modified by a different property animator, then the
	/// animators combine their changes in the most appropriate way. For many properties, the changes from each
	/// animator are added together to yield a new intermediate value. If a property can’t be modified in this
	/// additive manner, the new animations take over as if the beginFromCurrentState option had been specified
	/// for a view-based animation.
	///
	/// You can call this method multiple times to add multiple blocks to the animator.
	func addAnimations(_ animation: @escaping () -> Void)

	/// Adds the specified completion block to the animator.
	///
	/// Completion blocks are executed after the animations finish normally.
	///
	/// - Parameters:
	///   - completion: A block to execute when the animations finish. This block has no return value and takes
	///   the following parameter:
	///
	///     finalPosition
	///
	///     The ending position of the animations. Use this value to determine whether the animations stopped at
	///     the beginning, end, or somewhere in the middle.
	func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void)
}

extension Animator where Self: UIViewImplicitlyAnimating {
	public func addAnimations(_ animation: @escaping () -> Void) {
		addAnimations?(animation)
	}

	public func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
		addCompletion?(completion)
	}
}

extension UIViewPropertyAnimator: Animator {}

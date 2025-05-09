import Animator
public import UIKit

/// Defines a transition which applies to two views: an origin ("from") view and a destination ("to") view.
///
/// This protocol variant is used to implement transitions that need to interact with raw UIKit transitioning entities.
///
/// - Warning: Usage of this initializer is highly discouraged unless you know what you're doing.
/// Conform to ``NavigationTransitionProtocol`` instead to ensure correct transition behavior.
public protocol PrimitiveNavigationTransition {
	/// Typealias for `NavigationTransitionOperation`.
	typealias TransitionOperation = NavigationTransitionOperation
	/// Typealias for `UIViewControllerContextTransitioning`.
	typealias Context = UIViewControllerContextTransitioning

	/// Used to implement a custom navigation transition.
	///
	/// - Parameters:
	///   - Animator: The `Animator` object used for the transition. Attach animations or completion blocks to it.
	///   - Operation: The ``TransitionOperation``. Possible values are `push` or `pop`. It's recommended that you
	///   customize the behavior of your transition based on this parameter.
	///   - Context: The raw `UIViewControllerContextTransitioning` instance of the transition coordinator.
	func transition(with animator: any Animator, for operation: TransitionOperation, in context: any Context)
}

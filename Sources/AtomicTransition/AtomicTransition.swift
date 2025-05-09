import class Animator.AnimatorTransientView
public import class UIKit.UIView

/// Defines an atomic transition which applies to a single view. It is the core building block of
/// `NavigationTransition`.
///
/// Similarly to SwiftUI's `AnyTransition`, `AtomicTransition` is designed to handle both the insertion and the removal
/// of a view, and is agnostic as to what the overarching operation (push vs pop) is. This design allows great
/// composability when defining complex navigation transitions.
public protocol AtomicTransition {
	/// Typealias for `AtomicTransitionOperation`.
	typealias TransitionOperation = AtomicTransitionOperation
	/// Typealias for `AnimatorTransientView`.
	typealias TransientView = AnimatorTransientView
	/// Typealias for `UIView`.
	typealias Container = UIView

	/// Set up a custom atomic transition within this function.
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

/// Defines an `AtomicTransition` that can be mirrored. It is a specialized building block of `NavigationTransition`.
///
/// A transition that conform to these protocol expose a `Mirrored` associated type expressing the type resulting
/// from mirroring the transition.
public protocol MirrorableAtomicTransition: AtomicTransition {
	associatedtype Mirrored: AtomicTransition

	/// The mirrored transition.
	///
	/// > Note: A good indicator of a proper implementation for this function is that it should round-trip
	/// > to its original value when called twice:
	/// >
	/// > ```swift
	/// > Offset(x: 10).mirrored().mirrored() == Offset(x: 10)
	/// > ```
	func mirrored() -> Mirrored
}

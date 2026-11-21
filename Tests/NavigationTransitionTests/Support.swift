@testable import Animator
import NavigationTransition
import UIKit

/// A pair of views to run navigation transitions on, in a container of 100 × 200 points.
@MainActor
struct TransitionViews {
	let from = AnimatorTransientView(UIView())
	let to = AnimatorTransientView(UIView())
	let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))

	/// Names the view, for recording which one a transition received.
	func name(of view: AnimatorTransientView) -> String {
		if view === from {
			"from"
		} else if view === to {
			"to"
		} else {
			"unknown"
		}
	}

	func run(_ transition: some NavigationTransitionProtocol, for operation: NavigationTransitionOperation) {
		transition.transition(from: from, to: to, for: operation, in: container)
	}
}

extension AnimatorTransientViewProperties {
	/// The properties of a view that hasn't been changed, with no property set by a transition.
	static var unchanged: Self {
		Self(alpha: 1, transform: .identity, zPosition: 0)
	}
}

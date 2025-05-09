public import Animator
public import UIKit

/// A transition that changes the view layer’s position on the z axis.
public struct ZPosition: MirrorableAtomicTransition {
	private var zPosition: CGFloat

	public init(_ zPosition: CGFloat) {
		self.zPosition = zPosition
	}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		view.animation.zPosition = zPosition
		view.completion.zPosition = 0
	}

	@inlinable
	public func mirrored() -> Self {
		self
	}
}

/// A transition that brings the view to the front, regardless of insertion or removal.
public struct BringToFront: AtomicTransition {
	public init() {}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		container.bringSubviewToFront(view.uiView)
	}
}

extension BringToFront: Hashable {}

/// A transition that sends the view to the back, regardless of insertion or removal.
public struct SendToBack: AtomicTransition {
	public init() {}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		container.sendSubviewToBack(view.uiView)
	}
}

extension SendToBack: Hashable {}

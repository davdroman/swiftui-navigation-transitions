import SwiftUI

/// A transition that rotates the view from `angle` to zero on insertion, and from zero to `angle` on removal.
public struct Rotate: MirrorableAtomicTransition {
	private let angle: Angle

	public init(_ angle: Angle) {
		self.angle = angle
	}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		switch operation {
		case .insertion:
			view.initial.transform.rotate(by: angle.radians, z: 1)
			view.animation.transform = .identity
		case .removal:
			view.animation.transform.rotate(by: angle.radians, z: 1)
			view.completion.transform = .identity
		}
	}

	public func mirrored() -> Rotate {
		.init(.radians(-angle.radians))
	}
}

extension Rotate: Hashable {}

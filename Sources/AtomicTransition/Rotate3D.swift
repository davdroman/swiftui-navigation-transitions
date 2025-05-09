public import Animator
public import SwiftUI

/// A transition that rotates the view from `angle` to zero on insertion, and from zero to `angle` on removal.
public struct Rotate3D: MirrorableAtomicTransition {
	private let angle: Angle
	private let axis: (x: CGFloat, y: CGFloat, z: CGFloat)
	private let perspective: CGFloat

	public init(_ angle: Angle, axis: (x: CGFloat, y: CGFloat, z: CGFloat), perspective: CGFloat = 1) {
		self.angle = angle
		self.axis = axis
		self.perspective = perspective
	}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		let m34 = perspective / max(view.frame.width, view.frame.height)
		switch operation {
		case .insertion:
			view.uiView.layer.isDoubleSided = false
			view.initial.transform.m34 = m34
			view.initial.transform.rotate(by: angle.radians, x: axis.x, y: axis.y, z: axis.z)
			view.animation.transform = .identity
		case .removal:
			view.uiView.layer.isDoubleSided = false
			view.animation.transform.m34 = -m34
			view.animation.transform.rotate(by: angle.radians, x: axis.x, y: axis.y, z: axis.z)
			view.completion.transform = .identity
		}
	}

	public func mirrored() -> Rotate3D {
		.init(.degrees(angle.degrees), axis: axis, perspective: -perspective)
	}
}

extension Rotate3D: Hashable {
	public static func == (lhs: Rotate3D, rhs: Rotate3D) -> Bool {
		lhs.angle == rhs.angle
			&& lhs.axis == rhs.axis
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(angle)
		hasher.combine(axis.x)
		hasher.combine(axis.y)
		hasher.combine(axis.z)
	}
}

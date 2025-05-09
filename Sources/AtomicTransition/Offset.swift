public import UIKit

/// A transition that translates the view from offset to zero on insertion, and from zero to offset on removal.
public struct Offset: MirrorableAtomicTransition {
	private let x: CGFloat
	private let y: CGFloat

	public init(x: CGFloat, y: CGFloat) {
		self.x = x
		self.y = y
	}

	public init(x: CGFloat) {
		self.init(x: x, y: 0)
	}

	public init(y: CGFloat) {
		self.init(x: 0, y: y)
	}

	public init(_ offset: CGSize) {
		self.init(x: offset.width, y: offset.height)
	}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		switch operation {
		case .insertion:
			view.initial.transform.translate(x: x, y: y)
			view.animation.transform = .identity
		case .removal:
			view.animation.transform.translate(x: x, y: y)
			view.completion.transform = .identity
		}
	}

	public func mirrored() -> Offset {
		.init(x: -x, y: -y)
	}
}

extension Offset: Hashable {}

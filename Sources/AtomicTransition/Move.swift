import SwiftUI

/// A transition entering from `edge` on insertion, and exiting towards `edge` on removal.
public struct Move: MirrorableAtomicTransition {
	private let edge: Edge

	public init(edge: Edge) {
		self.edge = edge
	}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		switch (edge, operation) {
		case (.top, .insertion):
			view.initial.transform.translate(y: -container.frame.height)
			view.animation.transform = .identity

		case (.leading, .insertion):
			view.initial.transform.translate(x: -container.frame.width)
			view.animation.transform = .identity

		case (.trailing, .insertion):
			view.initial.transform.translate(x: container.frame.width)
			view.animation.transform = .identity

		case (.bottom, .insertion):
			view.initial.transform.translate(y: container.frame.height)
			view.animation.transform = .identity

		case (.top, .removal):
			view.animation.transform.translate(y: -container.frame.height)
			view.completion.transform = .identity

		case (.leading, .removal):
			view.animation.transform.translate(x: -container.frame.width)
			view.completion.transform = .identity

		case (.trailing, .removal):
			view.animation.transform.translate(x: container.frame.width)
			view.completion.transform = .identity

		case (.bottom, .removal):
			view.animation.transform.translate(y: container.frame.height)
			view.completion.transform = .identity
		}
	}

	public func mirrored() -> Move {
		switch edge {
		case .top:
			return .init(edge: .bottom)
		case .leading:
			return .init(edge: .trailing)
		case .bottom:
			return .init(edge: .top)
		case .trailing:
			return .init(edge: .leading)
		}
	}
}

extension Move: Hashable {}

@_spi(CATransform3DExtensions) import Animator
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
            view.initial.layer.transform.translate(x: 0, y: -container.frame.height, z: 0)
            view.animation.layer.transform = .identity

        case (.leading, .insertion):
            view.initial.layer.transform.translate(x: -container.frame.width, y: 0, z: 0)
            view.animation.layer.transform = .identity

        case (.trailing, .insertion):
            view.initial.layer.transform.translate(x: container.frame.width, y: 0, z: 0)
            view.animation.layer.transform = .identity

        case (.bottom, .insertion):
            view.initial.layer.transform.translate(x: 0, y: container.frame.height, z: 0)
            view.animation.layer.transform = .identity

        case (.top, .removal):
            view.animation.layer.transform.translate(x: 0, y: -container.frame.height, z: 0)
            view.completion.layer.transform = .identity

        case (.leading, .removal):
            view.animation.layer.transform.translate(x: -container.frame.width, y: 0, z: 0)
            view.completion.layer.transform = .identity

        case (.trailing, .removal):
            view.animation.layer.transform.translate(x: container.frame.width, y: 0, z: 0)
            view.completion.layer.transform = .identity

        case (.bottom, .removal):
            view.animation.layer.transform.translate(x: 0, y: container.frame.height, z: 0)
            view.completion.layer.transform = .identity
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

@_spi(CATransform3DExtensions) import Animator
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
            view.initial.layer.transform.rotate(by: angle.radians)
            view.animation.layer.transform = .identity
        case .removal:
            view.animation.layer.transform.rotate(by: angle.radians)
            view.completion.layer.transform = .identity
        }
    }

    public func mirrored() -> Rotate {
        .init(.radians(-angle.radians))
    }
}

extension Rotate: Hashable {}

import SwiftUI

/// A transition that rotates the view from `angle` to zero on insertion, and from zero to `angle` on removal.
public struct Rotate: AtomicTransitionProtocol {
    private let angle: Angle

    public init(_ angle: Angle) {
        self.angle = angle
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        switch operation {
        case .insertion:
            view.initial.rotation += angle.radians
            view.animation.transform = .identity
        case .removal:
            view.animation.rotation += angle.radians
            view.completion.transform = .identity
        }
    }
}

extension Rotate: Hashable {}

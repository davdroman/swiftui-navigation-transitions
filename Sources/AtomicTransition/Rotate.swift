import SwiftUI

extension AtomicTransition {
    /// A transition that rotates the view from `angle` to zero on insertion, and from zero to `angle` on removal.
    public static func rotate(_ angle: Angle) -> Self {
        .custom { view, operation, container in
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
}

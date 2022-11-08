import UIKit

extension AtomicTransition {
    /// A transition that translates the view from `offset` to zero on insertion, and from zero to `offset` on removal.
    public static func offset(x: CGFloat, y: CGFloat) -> Self {
        .custom { view, operation, _ in
            switch operation {
            case .insertion:
                view.initial.translation.dx += x
                view.initial.translation.dy += y
                view.animation.transform = .identity
            case .removal:
                view.animation.translation.dx += x
                view.animation.translation.dy += y
                view.completion.transform = .identity
            }
        }
    }

    /// A transition that translates the view from `offset` to zero on insertion, and from zero to `offset` on removal.
    @inlinable
    public static func offset(x: CGFloat) -> Self {
        .offset(x: x, y: 0)
    }

    /// A transition that translates the view from `offset` to zero on insertion, and from zero to `offset` on removal.
    @inlinable
    public static func offset(y: CGFloat) -> Self {
        .offset(x: 0, y: y)
    }

    /// A transition that translates the view from `offset` to zero on insertion, and from zero to `offset` on removal.
    @inlinable
    public static func offset(_ offset: CGSize) -> Self {
        .offset(x: offset.width, y: offset.height)
    }
}

/// A transition that translates the view from offset to zero on insertion, and from zero to offset on removal.
public struct Offset: AtomicTransitionProtocol {
    private let x: CGFloat
    private let y: CGFloat

    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        switch operation {
        case .insertion:
            view.initial.translation.dx += x
            view.initial.translation.dy += y
            view.animation.transform = .identity
        case .removal:
            view.animation.translation.dx += x
            view.animation.translation.dy += y
            view.completion.transform = .identity
        }
    }
}

extension Offset: Hashable {}

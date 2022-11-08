import UIKit

extension AtomicTransition {
    /// A transition that scales the view from `scale` to `1` on insertion, and from `1` to `scale` on removal.
    ///
    /// - Parameters:
    ///   - scale: The scale of the view, ranging from `0` to `1`.
    public static func scale(_ scale: CGFloat) -> Self {
        .custom { view, operation, container in
            switch operation {
            case .insertion:
                view.initial.scale = .init(width: scale, height: scale)
                view.animation.transform = .identity
            case .removal:
                view.animation.scale = .init(width: scale, height: scale)
                view.completion.transform = .identity
            }
        }
    }

    /// A transition that scales the view from `scale` to 1.0 on insertion, and from 1.0 to `scale` on removal.
    public static var scale: Self {
        .scale(.leastNonzeroMagnitude)
    }
}

/// A transition that scales the view from `scale` to `1` on insertion, and from `1` to `scale` on removal.
public struct Scale: AtomicTransitionProtocol {
    private let scale: CGFloat

    /// Returns a transition that scales the view from `scale` to 1.0 on insertion, and from 1.0 to `scale` on removal.
    /// 
    /// - Parameters:
    ///   - scale: The scale of the view, ranging from `0` to `1`.
    public init(_ scale: CGFloat) {
        self.scale = scale
    }

    /// Returns a transition that scales the view from 0 to 1.0 on insertion, and from 1.0 to 0 on removal.
    public init() {
        self.init(.leastNonzeroMagnitude)
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        switch operation {
        case .insertion:
            view.initial.scale = .init(width: scale, height: scale)
            view.animation.transform = .identity
        case .removal:
            view.animation.scale = .init(width: scale, height: scale)
            view.completion.transform = .identity
        }
    }
}

extension Scale: Hashable {}

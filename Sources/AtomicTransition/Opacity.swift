import class UIKit.UIView

/// A transition from transparent to opaque on insertion, and from opaque to transparent on removal.
public struct Opacity: AtomicTransitionProtocol {
    public init() {}

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        switch operation {
        case .insertion:
            view.initial.alpha = 0
            view.animation.alpha = 1
        case .removal:
            view.animation.alpha = 0
            view.completion.alpha = 1
        }
    }
}

extension Opacity: Hashable {}

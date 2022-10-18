extension AtomicTransition {
    /// A transition from transparent to opaque on insertion, and from opaque to transparent on removal.
    public static var opacity: Self {
        .custom { view, operation, _ in
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
}

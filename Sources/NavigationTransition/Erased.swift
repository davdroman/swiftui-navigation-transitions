// A type erased transition for internal use only.
struct Erased: NavigationTransition {
    private let handler: AnyNavigationTransition.TransientHandler

    init(handler: @escaping AnyNavigationTransition.TransientHandler) {
        self.handler = handler
    }

    func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        handler(fromView, toView, operation, container)
    }
}

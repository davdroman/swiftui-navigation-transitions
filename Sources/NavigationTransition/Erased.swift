// A type erased transition for internal use only.
struct Erased: NavigationTransitionProtocol {
    private let handler: AnyNavigationTransition.Handler

    init(handler: @escaping AnyNavigationTransition.Handler) {
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

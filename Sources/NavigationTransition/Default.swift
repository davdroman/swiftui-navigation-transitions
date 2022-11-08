extension NavigationTransition {
    /// The system-default transition.
    ///
    /// Use this property if you wish to modify the interactivity of the transition without altering the
    /// system-provided transition itself. For example:
    ///
    ///   ```swift
    ///   NavigationStack {
    ///     // ...
    ///   }
    ///   .navigationStackTransition(.default, interactivity: .pan) // enables full-screen panning for system-provided pop
    ///   ```
    ///
    /// - Note: The animation for `default` cannot be customized via ``animation(_:)``.
    public static var `default`: Self {
        var transition = Self { _, _, _ in }
        transition.isDefault = true
        return transition
    }
}

public struct Default: NavigationTransitionProtocol {
    public init() {}

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        runtimeWarn(
            """
            'Default' transition was used in conjunction with another transition.
            This won't produce the expected outcome, as 'Default' is a special-cased transition only used
            as a reference to the system default navigation transition and doesn't actually contain information
            about how the transition is performed.
            """
        )
    }
}

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

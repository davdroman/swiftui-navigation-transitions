extension AnyNavigationTransition {
	/// The system-default transition.
	///
	/// Use this transition if you wish to modify the interactivity of the transition without altering the
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
		.init(Default())
	}
}

package struct Default: PrimitiveNavigationTransition {
	init() {}

	package func transition(with animator: any Animator, for operation: TransitionOperation, in context: any Context) {
		// NO-OP
	}
}

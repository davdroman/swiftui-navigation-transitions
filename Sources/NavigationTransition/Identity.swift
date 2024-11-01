// For internal use only.
struct Identity: NavigationTransitionProtocol {
	init() {}

	func transition(
		from fromView: TransientView,
		to toView: TransientView,
		for operation: TransitionOperation,
		in container: Container
	) {
		// NO-OP
	}
}

extension Identity: Hashable {}

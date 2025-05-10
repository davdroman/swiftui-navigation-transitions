public import NavigationTransition

extension AnyNavigationTransition {
	public enum Interactivity {
		case disabled
		case edgePan
		case pan

		@inlinable
		public static var `default`: Self {
			.edgePan
		}
	}
}

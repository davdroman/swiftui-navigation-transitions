public import NavigationTransition

extension CustomNavigationTransition {
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

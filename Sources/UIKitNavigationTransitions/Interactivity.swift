public import NavigationTransition

extension CustomNavigationTransition {
	public enum Interactivity {
		/// Disables interactive pop gestures.
		case disabled
		/// Recognizes interactive pop gestures from the leading screen edge.
		case edgePan
		/// Recognizes interactive pop gestures across the content area on every supported iOS and Mac Catalyst version.
		case contentPan

		@available(*, deprecated, renamed: "contentPan")
		@inlinable
		public static var pan: Self {
			.contentPan
		}

		/// The default interactivity for the current platform version.
		///
		/// This is ``contentPan`` on iOS and Mac Catalyst 26 and later, and ``edgePan`` on earlier versions.
		@inlinable
		public static var `default`: Self {
			#if os(iOS)
			if #available(iOS 26, macCatalyst 26, *) {
				.contentPan
			} else {
				.edgePan
			}
			#else
			.edgePan
			#endif
		}
	}
}

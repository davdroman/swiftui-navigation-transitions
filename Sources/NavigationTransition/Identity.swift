extension NavigationTransition {
    // For internal use only.
    static var identity: Self {
        .init { _, _, _ in }
    }
}

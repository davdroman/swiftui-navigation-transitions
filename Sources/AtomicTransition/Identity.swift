extension AtomicTransition {
    /// A transition that returns the input view, unmodified, as the output view.
    public static var identity: Self {
        .init { _, _, _, _ in }
    }
}

extension Animation {
    public static func linear(duration: Double) -> Self {
        .init(duration: duration, curve: .linear)
    }

    public static var linear: Self {
        .linear(duration: defaultDuration)
    }
}

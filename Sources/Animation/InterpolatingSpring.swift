@MainActor
extension Animation {
	public static func interpolatingSpring(
		mass: Double = 1.0,
		stiffness: Double,
		damping: Double,
		initialVelocity: Double = 0.0,
	) -> Self {
		.init(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)
	}

	public static func interpolatingSpring(
		duration: Double = 0.5,
		bounce: Double = 0.0,
		initialVelocity: Double = 0.0,
	) -> Self {
		.springTiming(
			response: duration,
			dampingFraction: springDampingFraction(bounce: bounce),
			initialVelocity: initialVelocity,
		)
	}

	public static var interpolatingSpring: Self {
		.interpolatingSpring()
	}
}

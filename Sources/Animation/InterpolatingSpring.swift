extension Animation {
	public static func interpolatingSpring(
		mass: Double = 1.0,
		stiffness: Double,
		damping: Double,
		initialVelocity: Double = 0.0,
	) -> Self {
		precondition(mass > 0, "Spring mass must be greater than zero")
		precondition(stiffness > 0, "Spring stiffness must be greater than zero")
		return .init(spring: SpringTiming(
			mass: mass,
			stiffness: stiffness,
			damping: damping,
			style: .interpolating(initialVelocity: initialVelocity),
		))
	}

	public static func interpolatingSpring(
		duration: Double = 0.5,
		bounce: Double = 0.0,
		initialVelocity: Double = 0.0,
	) -> Self {
		let stiffness = springStiffness(response: duration)
		return .interpolatingSpring(
			stiffness: stiffness,
			damping: springDamping(fraction: springDampingFraction(bounce: bounce), stiffness: stiffness),
			initialVelocity: initialVelocity,
		)
	}

	public static var interpolatingSpring: Self {
		.interpolatingSpring()
	}
}

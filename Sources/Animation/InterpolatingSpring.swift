internal import UIKit // TODO: remove internal from all imports when Swift 5.10 is dropped

extension Animation {
	public static func interpolatingSpring(
		mass: Double = 1.0,
		stiffness: Double,
		damping: Double,
		initialVelocity: Double = 0.0
	) -> Self {
		.init(
			duration: defaultDuration,
			timingParameters: UISpringTimingParameters(
				mass: mass,
				stiffness: stiffness,
				damping: damping,
				initialVelocity: CGVector(dx: initialVelocity, dy: initialVelocity)
			)
		)
	}
}

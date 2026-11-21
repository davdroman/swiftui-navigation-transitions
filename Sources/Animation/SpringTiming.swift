import UIKit

/// A damped spring moving a value to its target.
struct SpringTiming: Sendable {
	enum Style: Sendable {
		/// SwiftUI's `spring` animations: the spring starts at rest, and damping past critical damping slows it down.
		case spring
		/// SwiftUI's `interpolatingSpring` animations: the spring starts at a velocity relative to the distance it
		/// travels, and damping is capped at critical damping.
		case interpolating(initialVelocity: Double)
	}

	/// The longest a spring takes to settle when bringing its damping closer to critical damping can make it settle
	/// sooner. A navigation transition holds up interaction until it finishes, and UIKit can't run a spring that never
	/// settles.
	static var maximumSettlingDuration: Double { 2 }

	var mass: Double
	var stiffness: Double
	var damping: Double
	var style: Style

	private var criticalDamping: Double {
		2 * (stiffness * mass).squareRoot()
	}

	private var initialVelocity: Double {
		switch style {
		case .spring: 0
		case let .interpolating(initialVelocity): initialVelocity
		}
	}

	func speed(_ speed: Double) -> Self {
		var copy = self
		copy.stiffness *= speed * speed
		copy.damping *= speed
		if case let .interpolating(initialVelocity) = style {
			copy.style = .interpolating(initialVelocity: initialVelocity * speed)
		}
		return copy
	}

	@MainActor
	func animatorTiming() -> AnimatorTiming {
		guard stiffness.isFinite else {
			// An infinitely stiff spring reaches its target immediately.
			return AnimatorTiming(
				duration: Animation.instantDuration,
				parameters: UICubicTimingParameters(animationCurve: .linear),
			)
		}
		if case .spring = style, damping > criticalDamping {
			return overdampedTiming()
		}
		return underdampedTiming()
	}

	@MainActor
	private func springTiming(damping: Double) -> AnimatorTiming {
		let parameters = UISpringTimingParameters(
			mass: mass,
			stiffness: stiffness,
			damping: damping,
			initialVelocity: CGVector(dx: initialVelocity, dy: initialVelocity),
		)
		return AnimatorTiming(
			duration: UIViewPropertyAnimator(duration: 0, timingParameters: parameters).duration,
			parameters: parameters,
		)
	}

	@MainActor
	private func underdampedTiming() -> AnimatorTiming {
		var tooLittleDamping = min(damping, criticalDamping)
		let requested = springTiming(damping: tooLittleDamping)
		guard requested.duration > Self.maximumSettlingDuration else {
			return requested
		}
		var timing = springTiming(damping: criticalDamping)
		guard timing.duration <= Self.maximumSettlingDuration else {
			return timing
		}
		var enoughDamping = criticalDamping
		for _ in 0..<24 {
			let damping = (tooLittleDamping + enoughDamping) / 2
			let candidate = springTiming(damping: damping)
			if candidate.duration <= Self.maximumSettlingDuration {
				enoughDamping = damping
				timing = candidate
			} else {
				tooLittleDamping = damping
			}
		}
		return timing
	}

	/// UIKit runs springs damped past critical damping as critically damped ones, so the motion runs on a cubic
	/// Bézier curve that approximates it instead.
	@MainActor
	private func overdampedTiming() -> AnimatorTiming {
		// Closer to critical damping, UIKit's critically damped spring stays within 0.05% of the motion.
		let minimumDampingRatio = 1.001
		let angularFrequency = (stiffness / mass).squareRoot()
		let maximumSettlingTime = Self.maximumSettlingDuration * angularFrequency
		let critical = springTiming(damping: criticalDamping)
		guard
			damping / criticalDamping > minimumDampingRatio,
			OverdampedSpring(dampingRatio: minimumDampingRatio).settlingTime <= maximumSettlingTime
		else {
			return critical
		}

		// A spring settles no sooner than its damping ratio times log(1 / threshold), so this ratio settles too late.
		var tooMuchDamping = min(damping / criticalDamping, 1 + maximumSettlingTime)
		var spring = OverdampedSpring(dampingRatio: tooMuchDamping)
		if spring.settlingTime > maximumSettlingTime {
			var enoughDamping = minimumDampingRatio
			for _ in 0..<40 {
				let dampingRatio = (tooMuchDamping + enoughDamping) / 2
				if OverdampedSpring(dampingRatio: dampingRatio).settlingTime <= maximumSettlingTime {
					enoughDamping = dampingRatio
				} else {
					tooMuchDamping = dampingRatio
				}
			}
			spring = OverdampedSpring(dampingRatio: enoughDamping)
		}

		let approximation = spring.cubicApproximation()
		guard approximation.error < spring.criticallyDampedError else {
			return critical
		}
		return AnimatorTiming(
			duration: spring.settlingTime / angularFrequency,
			parameters: UICubicTimingParameters(
				controlPoint1: approximation.controlPoint1,
				controlPoint2: approximation.controlPoint2,
			),
		)
	}
}

package import UIKit

public struct Animation {
	static var defaultDuration: Double { 0.35 }

	package var duration: Double
	private var timing: Timing

	private enum Timing {
		case curve(UIView.AnimationCurve)
		case controlPoints(CGPoint, CGPoint)
		case spring(mass: Double, stiffness: Double, damping: Double, initialVelocity: Double)
	}

	init(duration: Double, curve: UIView.AnimationCurve) {
		self.duration = duration
		self.timing = .curve(curve)
	}

	init(duration: Double, controlPoint1: CGPoint, controlPoint2: CGPoint) {
		self.duration = duration
		self.timing = .controlPoints(controlPoint1, controlPoint2)
	}

	/// Animators ignore `duration` for springs and run them for their settling duration instead.
	init(mass: Double, stiffness: Double, damping: Double, initialVelocity: Double) {
		self.duration = Self.defaultDuration
		self.timing = .spring(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)
	}

	@MainActor
	package var timingParameters: any UITimingCurveProvider {
		switch timing {
		case let .curve(curve):
			UICubicTimingParameters(animationCurve: curve)
		case let .controlPoints(controlPoint1, controlPoint2):
			UICubicTimingParameters(controlPoint1: controlPoint1, controlPoint2: controlPoint2)
		case let .spring(mass, stiffness, damping, initialVelocity):
			UISpringTimingParameters(
				mass: mass,
				stiffness: stiffness,
				damping: damping,
				initialVelocity: CGVector(dx: initialVelocity, dy: initialVelocity),
			)
		}
	}
}

extension Animation {
	public func speed(_ speed: Double) -> Self {
		var copy = self
		copy.duration /= speed
		if case let .spring(mass, stiffness, damping, initialVelocity) = timing {
			copy.timing = .spring(
				mass: mass,
				stiffness: stiffness * speed * speed,
				damping: damping * speed,
				initialVelocity: initialVelocity * speed,
			)
		}
		return copy
	}
}

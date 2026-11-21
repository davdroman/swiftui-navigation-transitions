package import UIKit

public struct Animation: Sendable {
	static var defaultDuration: Double { 0.35 }

	/// The duration of animations that finish immediately. Animators given no duration run for a default one instead.
	static var instantDuration: Double { .leastNormalMagnitude }

	private(set) var timing: Timing

	enum Timing: Sendable {
		case curve(UIView.AnimationCurve, duration: Double)
		case controlPoints(CGPoint, CGPoint, duration: Double)
		case spring(SpringTiming)
	}

	init(duration: Double, curve: UIView.AnimationCurve) {
		self.timing = .curve(curve, duration: duration)
	}

	init(duration: Double, controlPoint1: CGPoint, controlPoint2: CGPoint) {
		self.timing = .controlPoints(controlPoint1, controlPoint2, duration: duration)
	}

	init(spring: SpringTiming) {
		self.timing = .spring(spring)
	}

	/// How long an animator runs this animation for, and its timing curve. Springs run for their settling duration.
	@MainActor
	package func animatorTiming() -> AnimatorTiming {
		switch timing {
		case let .curve(curve, duration):
			AnimatorTiming(
				duration: max(duration, Self.instantDuration),
				parameters: UICubicTimingParameters(animationCurve: curve),
			)
		case let .controlPoints(controlPoint1, controlPoint2, duration):
			AnimatorTiming(
				duration: max(duration, Self.instantDuration),
				parameters: UICubicTimingParameters(controlPoint1: controlPoint1, controlPoint2: controlPoint2),
			)
		case let .spring(spring):
			spring.animatorTiming()
		}
	}
}

package struct AnimatorTiming {
	package var duration: TimeInterval
	package var parameters: any UITimingCurveProvider

	@MainActor
	package func makeAnimator() -> UIViewPropertyAnimator {
		UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
	}
}

extension Animation {
	public func speed(_ speed: Double) -> Self {
		precondition(speed > 0, "Animation speed must be greater than zero")
		var copy = self
		switch timing {
		case let .curve(curve, duration):
			copy.timing = .curve(curve, duration: duration / speed)
		case let .controlPoints(controlPoint1, controlPoint2, duration):
			copy.timing = .controlPoints(controlPoint1, controlPoint2, duration: duration / speed)
		case let .spring(spring):
			copy.timing = .spring(spring.speed(speed))
		}
		return copy
	}
}

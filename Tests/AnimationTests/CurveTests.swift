@testable import Animation
import Testing
import UIKit

@MainActor
struct CurveTests {
	@Test(arguments: [
		(Animation.default, UIView.AnimationCurve.easeInOut, 0.35),
		(.linear, .linear, 0.35),
		(.linear(duration: 0.2), .linear, 0.2),
		(.easeIn, .easeIn, 0.35),
		(.easeIn(duration: 0.2), .easeIn, 0.2),
		(.easeOut, .easeOut, 0.35),
		(.easeOut(duration: 0.2), .easeOut, 0.2),
		(.easeInOut, .easeInOut, 0.35),
		(.easeInOut(duration: 0.2), .easeInOut, 0.2),
	])
	func `system curves run for their duration`(
		animation: Animation,
		curve: UIView.AnimationCurve,
		duration: Double,
	) throws {
		let timing = animation.animatorTiming()
		let parameters = try #require(timing.parameters as? UICubicTimingParameters)

		#expect(timing.duration == duration)
		#expect(parameters.animationCurve == curve)
	}

	@Test(arguments: [
		(Animation.timingCurve(0.1, 0.2, 0.3, 0.4), 0.35),
		(.timingCurve(0.1, 0.2, 0.3, 0.4, duration: 0.6), 0.6),
	])
	func `timing curves use their control points`(animation: Animation, duration: Double) throws {
		let timing = animation.animatorTiming()
		let parameters = try #require(timing.parameters as? UICubicTimingParameters)

		#expect(timing.duration == duration)
		#expect(parameters.controlPoint1 == CGPoint(x: 0.1, y: 0.2))
		#expect(parameters.controlPoint2 == CGPoint(x: 0.3, y: 0.4))
	}

	@Test(arguments: [
		Animation.linear(duration: 0.6),
		.easeInOut(duration: 0.6),
		.timingCurve(0.1, 0.2, 0.3, 0.4, duration: 0.6),
	])
	func `speed divides the duration of curves`(animation: Animation) throws {
		let original = animation.animatorTiming()
		let faster = animation.speed(2).animatorTiming()
		let originalParameters = try #require(original.parameters as? UICubicTimingParameters)
		let fasterParameters = try #require(faster.parameters as? UICubicTimingParameters)

		#expect(faster.duration == 0.3)
		#expect(fasterParameters.animationCurve == originalParameters.animationCurve)
		#expect(fasterParameters.controlPoint1 == originalParameters.controlPoint1)
		#expect(fasterParameters.controlPoint2 == originalParameters.controlPoint2)
	}
}

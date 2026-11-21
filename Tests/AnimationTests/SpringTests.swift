@testable import Animation
import struct SwiftUI.Spring
import UIKit
import XCTest

@MainActor
final class SpringTests: XCTestCase {
	func testSpringsMatchSwiftUI() throws {
		guard #available(iOS 17, tvOS 17, *) else {
			throw XCTSkip("SwiftUI's Spring requires iOS 17")
		}
		let cases: [(Animation, Spring)] = [
			(.spring, Spring(duration: 0.5, bounce: 0)),
			(.spring(duration: 0.4, bounce: 0.2), Spring(duration: 0.4, bounce: 0.2)),
			(.spring(response: 0.3, dampingFraction: 0.7), Spring(response: 0.3, dampingRatio: 0.7)),
			(.interactiveSpring, Spring(duration: 0.15, bounce: 0.15)),
			(.interactiveSpring(response: 0.2, dampingFraction: 0.9), Spring(response: 0.2, dampingRatio: 0.9)),
			(.smooth(duration: 0.3), .smooth(duration: 0.3)),
			(.snappy, .snappy),
			(.bouncy(duration: 0.6, extraBounce: 0.1), .bouncy(duration: 0.6, extraBounce: 0.1)),
			(.interpolatingSpring(duration: 0.4, bounce: 0.2), Spring(duration: 0.4, bounce: 0.2)),
			(.interpolatingSpring(mass: 2, stiffness: 300, damping: 20), Spring(mass: 2, stiffness: 300, damping: 20)),
		]
		for (animation, spring) in cases {
			let timing = try XCTUnwrap(springTiming(animation))
			XCTAssertEqual(timing.mass, spring.mass, accuracy: 1e-9)
			XCTAssertEqual(timing.stiffness, spring.stiffness, accuracy: 1e-9)
			XCTAssertEqual(timing.damping, spring.damping, accuracy: 1e-9)
		}
	}

	func testOverdampedSpringsFollowSwiftUI() throws {
		guard #available(iOS 17, tvOS 17, *) else {
			throw XCTSkip("SwiftUI's Spring requires iOS 17")
		}
		let cases: [(Animation, Spring)] = [
			(.spring(duration: 0.4, bounce: -0.05), Spring(duration: 0.4, bounce: -0.05)),
			(.spring(duration: 0.4, bounce: -0.2), Spring(duration: 0.4, bounce: -0.2)),
			(.spring(duration: 0.4, bounce: -0.5), Spring(duration: 0.4, bounce: -0.5)),
			(.spring(duration: 0.2, bounce: -0.7), Spring(duration: 0.2, bounce: -0.7)),
			(.spring(response: 0.3, dampingFraction: 1.5), Spring(response: 0.3, dampingRatio: 1.5)),
			(.smooth(duration: 0.25, extraBounce: -0.4), .smooth(duration: 0.25, extraBounce: -0.4)),
		]
		for (animation, spring) in cases {
			let animator = animation.animatorTiming().makeAnimator()
			XCTAssertLessThanOrEqual(animator.duration, SpringTiming.maximumSettlingDuration)
			for (time, progress) in sampleProgress(animator) {
				XCTAssertEqual(progress, spring.value(target: 1.0, time: time), accuracy: 0.025, "\(spring) at \(time)s")
			}
		}
	}

	func testInterpolatingSpringsCapDampingAtCriticalDampingLikeSwiftUI() throws {
		guard #available(iOS 17, tvOS 17, *) else {
			throw XCTSkip("SwiftUI's Spring requires iOS 17")
		}
		let spring = Spring(mass: 1, stiffness: 246.74, damping: 62.83)
		let animator = Animation.interpolatingSpring(stiffness: 246.74, damping: 62.83).animatorTiming().makeAnimator()
		for (time, progress) in sampleProgress(animator) {
			XCTAssertEqual(progress, spring.value(target: 1.0, time: time), accuracy: 0.015, "at \(time)s")
		}
	}

	func testSpringsThatWouldNotSettleInTimeSettleWithinTheLimit() {
		let animations: [Animation] = [
			.spring(duration: 0.5, bounce: 1),
			.spring(duration: 0.5, bounce: 2),
			.bouncy(extraBounce: 0.7),
			.spring(response: 0.5, dampingFraction: 0),
			.spring(response: 0.5, dampingFraction: -0.5),
			.spring(duration: 0.3, bounce: 0.95),
			.interpolatingSpring(stiffness: 100, damping: 0),
			.interpolatingSpring(duration: 0.5, bounce: 1, initialVelocity: 3),
			.spring(duration: 0.5, bounce: -1),
			.spring(duration: 0.5, bounce: -0.95),
		]
		for animation in animations {
			let duration = animation.animatorTiming().duration
			XCTAssertLessThanOrEqual(duration, SpringTiming.maximumSettlingDuration, "\(animation)")
			XCTAssertGreaterThan(duration, SpringTiming.maximumSettlingDuration * 0.95, "\(animation)")
		}
	}

	func testSpringsThatCannotSettleInTimeAreCriticallyDamped() throws {
		guard #available(iOS 17, tvOS 17, *) else {
			throw XCTSkip("UISpringTimingParameters(duration:bounce:) requires iOS 17")
		}
		let critical = UIViewPropertyAnimator(
			duration: 0,
			timingParameters: UISpringTimingParameters(duration: 3, bounce: 0),
		)
		XCTAssertGreaterThan(critical.duration, SpringTiming.maximumSettlingDuration)
		for animation in [
			Animation.smooth(duration: 3),
			.bouncy(duration: 3, extraBounce: 0.7),
			.spring(duration: 3, bounce: -0.5),
		] {
			XCTAssertEqual(animation.animatorTiming().duration, critical.duration, accuracy: 1e-9, "\(animation)")
		}
	}

	func testSpeedScalesSprings() {
		let cases: [(Animation, Animation)] = [
			(.smooth(duration: 0.6).speed(2), .smooth(duration: 0.3)),
			(.spring(duration: 0.8, bounce: -0.5).speed(2), .spring(duration: 0.4, bounce: -0.5)),
			(
				.interpolatingSpring(duration: 0.6, initialVelocity: 2).speed(2),
				.interpolatingSpring(duration: 0.3, initialVelocity: 4),
			),
		]
		for (scaled, expected) in cases {
			XCTAssertEqual(
				scaled.animatorTiming().duration,
				expected.animatorTiming().duration,
				accuracy: 1e-6,
				"\(expected)",
			)
		}
	}

	private func springTiming(_ animation: Animation) -> SpringTiming? {
		guard case let .spring(timing) = animation.timing else {
			return nil
		}
		return timing
	}

	/// The animator's progress at points throughout its run, read from a view it moves 100 points.
	private func sampleProgress(_ animator: UIViewPropertyAnimator) -> [(time: Double, progress: Double)] {
		let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
		window.makeKeyAndVisible()
		defer { window.isHidden = true }
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
		window.addSubview(view)
		animator.addAnimations { view.frame.origin.x = 100 }
		animator.scrubsLinearly = false
		animator.pauseAnimation()
		defer {
			animator.stopAnimation(true)
		}
		return stride(from: 0.02, to: 1, by: 0.02).map { fraction in
			animator.fractionComplete = fraction
			CATransaction.flush()
			return (fraction * animator.duration, (view.layer.presentation()?.frame.origin.x ?? .nan) / 100)
		}
	}
}

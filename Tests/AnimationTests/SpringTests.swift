@testable import Animation
import UIKit
import XCTest

@MainActor
final class SpringTests: XCTestCase {
	func testSpringsSettleLikeUIKitSprings() throws {
		guard #available(iOS 17, tvOS 17, *) else {
			throw XCTSkip("UISpringTimingParameters(duration:bounce:) requires iOS 17")
		}
		let cases: [(Animation, duration: Double, bounce: Double)] = [
			(.spring, 0.5, 0),
			(.spring(duration: 0), 0, 0),
			(.spring(duration: 0.5, bounce: -1), 0.5, -1),
			(.spring(duration: 0.4, bounce: 0.2), 0.4, 0.2),
			(.spring(duration: 0.4, bounce: -0.5), 0.4, -0.5),
			(.smooth(duration: 0.3), 0.3, 0),
			(.snappy, 0.5, 0.15),
			(.bouncy(duration: 0.6, extraBounce: 0.1), 0.6, 0.4),
			(.interactiveSpring, 0.15, 0.15),
			(.interpolatingSpring(duration: 0.4, bounce: 0.2), 0.4, 0.2),
		]
		for (animation, duration, bounce) in cases {
			XCTAssertEqual(
				settlingDuration(animation),
				settlingDuration(UISpringTimingParameters(duration: duration, bounce: bounce)),
				accuracy: 0.000001,
				"duration: \(duration), bounce: \(bounce)",
			)
		}
	}

	func testSpeedScalesSprings() {
		XCTAssertEqual(
			settlingDuration(.smooth(duration: 0.6).speed(2)),
			settlingDuration(.smooth(duration: 0.3)),
			accuracy: 0.000001,
		)
	}

	private func settlingDuration(_ animation: Animation) -> Double {
		UIViewPropertyAnimator(duration: animation.duration, timingParameters: animation.timingParameters).duration
	}

	private func settlingDuration(_ timingParameters: UISpringTimingParameters) -> Double {
		UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
	}
}

@testable import Animation
import UIKit
import XCTest

@MainActor
final class AnimationTests: XCTestCase {
	func testZeroDurationAnimationsAreInstant() async throws {
		let animations: [Animation] = [
			.linear(duration: 0),
			.easeInOut(duration: 0),
			.timingCurve(0.2, 0, 0.2, 1, duration: 0),
			.spring(duration: 0),
			.spring(duration: 0, bounce: 1),
			.spring(response: 0, dampingFraction: 0.5),
			.bouncy(duration: 0),
			.interpolatingSpring(duration: 0),
		]
		let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
		window.makeKeyAndVisible()
		defer { window.isHidden = true }
		for animation in animations {
			let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
			window.addSubview(view)
			let animator = animation.animatorTiming().makeAnimator()
			animator.addAnimations { view.frame.origin.x = 100 }
			var completed = false
			animator.addCompletion { _ in completed = true }
			animator.startAnimation()
			for _ in 0..<5 where !completed {
				try await Task.sleep(for: .milliseconds(10))
			}
			XCTAssertTrue(completed, "\(animation)")
		}
	}
}

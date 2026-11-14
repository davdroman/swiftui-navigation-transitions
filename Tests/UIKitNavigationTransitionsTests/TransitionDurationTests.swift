import UIKit
@testable import UIKitNavigationTransitions
import XCTest

@MainActor
final class TransitionDurationTests: XCTestCase {
	func testCurveReportsItsDuration() {
		let sut = NavigationTransitionAnimatorProvider(
			transition: .slide,
			animation: .easeInOut(duration: 0.2),
			operation: .push,
		)

		XCTAssertEqual(sut.transitionDuration(using: nil), 0.2)
	}

	func testSpringReportsItsSettlingDuration() throws {
		guard #available(iOS 17, tvOS 17, *) else {
			throw XCTSkip("UISpringTimingParameters(duration:bounce:) requires iOS 17")
		}
		let sut = NavigationTransitionAnimatorProvider(
			transition: .slide,
			animation: .smooth(duration: 0.3),
			operation: .push,
		)
		let spring = UIViewPropertyAnimator(
			duration: 0,
			timingParameters: UISpringTimingParameters(duration: 0.3, bounce: 0),
		)

		XCTAssertEqual(sut.transitionDuration(using: nil), spring.duration, accuracy: 0.000001)
	}
}

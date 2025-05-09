@testable import Animator
import AtomicTransition
import TestUtils

final class ScaleTests: XCTestCase {
	let viewUsed = AnimatorTransientView(UIView())
	let properties = AnimatorTransientViewProperties(
		alpha: 1,
		transform: .identity,
		zPosition: 0
	)
	let containerUsed = UIView()

	func testInsertion() {
		Scale(0.5).transition(viewUsed, for: .insertion, in: containerUsed)

		var initial = properties
		initial.transform.scale(0.5)
		expectNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.rotate(by: 0, z: 1)
		expectNoDifference(viewUsed.animation, animation)

		let completion = properties
		expectNoDifference(viewUsed.completion, completion)
	}

	func testRemoval() {
		Scale(0.5).transition(viewUsed, for: .removal, in: containerUsed)

		let initial = properties
		expectNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.scale(0.5)
		expectNoDifference(viewUsed.animation, animation)

		var completion = properties
		completion.transform.rotate(by: 0, z: 1)
		expectNoDifference(viewUsed.completion, completion)
	}

	func testConveniences() {
		XCTAssertEqual(Scale(), Scale(.leastNonzeroMagnitude))
	}
}

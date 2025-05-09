@testable import Animator
import AtomicTransition
import TestUtils

final class RotateTests: XCTestCase {
	let viewUsed = AnimatorTransientView(UIView())
	let properties = AnimatorTransientViewProperties(
		alpha: 1,
		transform: .identity,
		zPosition: 0
	)
	let containerUsed = UIView()

	func testInsertion() {
		Rotate(.radians(.pi)).transition(viewUsed, for: .insertion, in: containerUsed)

		var initial = properties
		initial.transform.rotate(by: .pi, z: 1)
		expectNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.rotate(by: 0)
		expectNoDifference(viewUsed.animation, animation)

		let completion = properties
		expectNoDifference(viewUsed.completion, completion)
	}

	func testRemoval() {
		Rotate(.radians(.pi)).transition(viewUsed, for: .removal, in: containerUsed)

		let initial = properties
		expectNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.rotate(by: .pi, z: 1)
		expectNoDifference(viewUsed.animation, animation)

		var completion = properties
		completion.transform.rotate(by: 0)
		expectNoDifference(viewUsed.completion, completion)
	}
}

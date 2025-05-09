@testable import Animator
import AtomicTransition
import TestUtils

final class OpacityTests: XCTestCase {
	let viewUsed = AnimatorTransientView(UIView())
	let properties = AnimatorTransientViewProperties(
		alpha: 1,
		transform: .identity,
		zPosition: 0
	)
	let containerUsed = UIView()

	func testInsertion() {
		Opacity().transition(viewUsed, for: .insertion, in: containerUsed)

		var initial = properties
		initial.alpha = 0
		expectNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.alpha = 1
		expectNoDifference(viewUsed.animation, animation)

		let completion = properties
		expectNoDifference(viewUsed.completion, completion)
	}

	func testRemoval() {
		Opacity().transition(viewUsed, for: .removal, in: containerUsed)

		let initial = properties
		expectNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.alpha = 0
		expectNoDifference(viewUsed.animation, animation)

		var completion = properties
		completion.alpha = 1
		expectNoDifference(viewUsed.completion, completion)
	}
}

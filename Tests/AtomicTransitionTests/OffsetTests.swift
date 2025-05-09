@testable import Animator
import AtomicTransition
import TestUtils

final class OffsetTests: XCTestCase {
	let viewUsed = AnimatorTransientView(UIView())
	let properties = AnimatorTransientViewProperties(
		alpha: 1,
		transform: .identity,
		zPosition: 0
	)
	let containerUsed = UIView()

	func testInsertion() {
		Offset(x: 100, y: 200).transition(viewUsed, for: .insertion, in: containerUsed)

		var initial = properties
		initial.transform.translate(x: 100, y: 200)
		expectNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: 0, y: 0)
		expectNoDifference(viewUsed.animation, animation)

		let completion = properties
		expectNoDifference(viewUsed.completion, completion)
	}

	func testRemoval() {
		Offset(x: 100, y: 200).transition(viewUsed, for: .removal, in: containerUsed)

		let initial = properties
		expectNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: 100, y: 200)
		expectNoDifference(viewUsed.animation, animation)

		var completion = properties
		completion.transform.translate(x: 0, y: 0)
		expectNoDifference(viewUsed.completion, completion)
	}

	func testConveniences() {
		XCTAssertEqual(Offset(x: 1), Offset(x: 1, y: 0))
		XCTAssertEqual(Offset(y: 1), Offset(x: 0, y: 1))
		XCTAssertEqual(Offset(.init(width: 1, height: 2)), Offset(x: 1, y: 2))
	}
}

@testable import Animator
import AtomicTransition
import TestUtils

final class MoveTests: XCTestCase {
	let viewUsed = AnimatorTransientView(UIView())
	let properties = AnimatorTransientViewProperties(
		alpha: 1,
		transform: .identity,
		zPosition: 0
	)
	let containerUsed: UIView = {
		let _containerUsed = UIView()
		_containerUsed.frame.size = .init(width: 100, height: 200)
		return _containerUsed
	}()
}

extension MoveTests {
	func testInitialState() {
		XCTAssertEqual(viewUsed.initial, properties)
		XCTAssertEqual(viewUsed.animation, properties)
		XCTAssertEqual(viewUsed.completion, properties)
	}
}

extension MoveTests {
	func testTopInsertion() {
		Move(edge: .top).transition(viewUsed, for: .insertion, in: containerUsed)

		var initial = properties
		initial.transform.translate(x: 0, y: -200, z: 0)
		XCTAssertNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: 0, y: 0, z: 0)
		XCTAssertNoDifference(viewUsed.animation, animation)

		let completion = properties
		XCTAssertNoDifference(viewUsed.completion, completion)
	}

	func testLeadingInsertion() {
		Move(edge: .leading).transition(viewUsed, for: .insertion, in: containerUsed)

		var initial = properties
		initial.transform.translate(x: -100, y: 0, z: 0)
		XCTAssertNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: 0, y: 0, z: 0)
		XCTAssertNoDifference(viewUsed.animation, animation)

		let completion = properties
		XCTAssertNoDifference(viewUsed.completion, completion)
	}

	func testTrailingInsertion() {
		Move(edge: .trailing).transition(viewUsed, for: .insertion, in: containerUsed)

		var initial = properties
		initial.transform.translate(x: 100, y: 0, z: 0)
		XCTAssertNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: 0, y: 0, z: 0)
		XCTAssertNoDifference(viewUsed.animation, animation)

		let completion = properties
		XCTAssertNoDifference(viewUsed.completion, completion)
	}

	func testBottomInsertion() {
		Move(edge: .bottom).transition(viewUsed, for: .insertion, in: containerUsed)

		var initial = properties
		initial.transform.translate(x: 0, y: 200, z: 0)
		XCTAssertNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: 0, y: 0, z: 0)
		XCTAssertNoDifference(viewUsed.animation, animation)

		let completion = properties
		XCTAssertNoDifference(viewUsed.completion, completion)
	}
}

extension MoveTests {
	func testTopRemoval() {
		Move(edge: .top).transition(viewUsed, for: .removal, in: containerUsed)

		let initial = properties
		XCTAssertNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: 0, y: -200)
		XCTAssertNoDifference(viewUsed.animation, animation)

		var completion = properties
		completion.transform.translate(x: 0, y: 0)
		XCTAssertNoDifference(viewUsed.completion, completion)
	}

	func testLeadingRemoval() {
		Move(edge: .leading).transition(viewUsed, for: .removal, in: containerUsed)

		let initial = properties
		XCTAssertNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: -100, y: 0)
		XCTAssertNoDifference(viewUsed.animation, animation)

		var completion = properties
		completion.transform.translate(x: 0, y: 0)
		XCTAssertNoDifference(viewUsed.completion, completion)
	}

	func testTrailingRemoval() {
		Move(edge: .trailing).transition(viewUsed, for: .removal, in: containerUsed)

		let initial = properties
		XCTAssertNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: 100, y: 0)
		XCTAssertNoDifference(viewUsed.animation, animation)

		var completion = properties
		completion.transform.translate(x: 0, y: 0)
		XCTAssertNoDifference(viewUsed.completion, completion)
	}

	func testBottomRemoval() {
		Move(edge: .bottom).transition(viewUsed, for: .removal, in: containerUsed)

		let initial = properties
		XCTAssertNoDifference(viewUsed.initial, initial)

		var animation = properties
		animation.transform.translate(x: 0, y: 200)
		XCTAssertNoDifference(viewUsed.animation, animation)

		var completion = properties
		completion.transform.translate(x: 0, y: 0)
		XCTAssertNoDifference(viewUsed.completion, completion)
	}
}

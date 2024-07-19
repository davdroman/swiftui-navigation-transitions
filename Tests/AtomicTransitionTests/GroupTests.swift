import AtomicTransition
import TestUtils

final class GroupTests: XCTestCase {
	func testEmpty() {
		XCTAssert(Group {} is Group<Identity>)
	}

	func testOne() {
		enum A {}
		XCTAssert(Group { Noop<A>() } is Group<Noop<A>>)
	}

	func testEquality() {
		XCTAssertEqual(Group {}, Group { Identity() })
		enum A {}
		XCTAssertEqual(Group { Noop<A>() }, Group { Noop<A>() })
	}

	func testExecutionOrder() {
		let expectation1 = expectation(description: "Transition 1")
		let expectation2 = expectation(description: "Transition 2")
		let expectation3 = expectation(description: "Transition 3")
		let expectation4 = expectation(description: "Transition 4")

		let sut = Group {
			Spy { expectation1.fulfill() }
			Spy { expectation2.fulfill() }
			Spy { expectation3.fulfill() }
			Spy { expectation4.fulfill() }
		}

		sut.transition(.unimplemented, for: .random(), in: .unimplemented)

		wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 0, enforceOrder: true)
	}
}

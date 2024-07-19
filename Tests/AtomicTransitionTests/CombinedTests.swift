@testable import AtomicTransition
import TestUtils

final class CombinedTests: XCTestCase {
	func testTwo() {
		enum A {}; enum B {}
		XCTAssert(Combined { Noop<A>(); Noop<B>() } is Combined<Noop<A>, Noop<B>>)
	}

	func testEquality() {
		enum A {}; enum B {}
		XCTAssertEqual(Combined { Noop<A>(); Noop<B>() }, Combined(Noop<A>(), Noop<B>()))
	}

	func testExecutionOrder() {
		let expectation1 = expectation(description: "Transition 1")
		let expectation2 = expectation(description: "Transition 2")
		let expectation3 = expectation(description: "Transition 3")
		let expectation4 = expectation(description: "Transition 4")

		let sut = Combined {
			Spy { expectation1.fulfill() }
			Spy { expectation2.fulfill() }
			Spy { expectation3.fulfill() }
			Spy { expectation4.fulfill() }
		}

		sut.transition(.unimplemented, for: .random(), in: .unimplemented)

		wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 0, enforceOrder: true)
	}
}

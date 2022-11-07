@_spi(package) import AtomicTransition
import TestUtils

final class GroupTests: XCTestCase {
    func testEmpty() {
        XCTAssert(Group {} is Group<Identity>)
    }

    func testOne() {
        XCTAssert(Group { Identity() } is Group<Identity>)
    }

    func testEquality() {
        XCTAssertEqual(Group {}, Group { Identity() })
        XCTAssertEqual(Group { Identity() }, Group { Identity() })
    }

    func testExecutionOrder() {
        let viewUsed = UnimplementedAnimatorTransientView()
        let operationUsed = AtomicTransitionOperation.random()
        let containerUsed = UIView()

        let expectation1 = self.expectation(description: "Transition 1")
        let expectation2 = self.expectation(description: "Transition 2")
        let expectation3 = self.expectation(description: "Transition 3")
        let expectation4 = self.expectation(description: "Transition 4")

        let sut = Group {
            Spy { view, operation, container in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(container, containerUsed)
                expectation1.fulfill()
            }
            Spy { view, operation, container in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(container, containerUsed)
                expectation2.fulfill()
            }
            Spy { view, operation, container in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(container, containerUsed)
                expectation3.fulfill()
            }
            Spy { view, operation, container in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(container, containerUsed)
                expectation4.fulfill()
            }
        }

        sut.transition(viewUsed, for: operationUsed, in: containerUsed)

        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 0, enforceOrder: true)
    }
}

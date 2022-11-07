@_spi(package) import AtomicTransition
import TestUtils

final class AtomicTransitionTests: XCTestCase {
    func testPrepare() {
        let viewUsed = UnimplementedAnimatorTransientView()
        let operationUsed = AtomicTransition.Operation.random()
        let contextUsed = UnimplementedUIKitContext()

        let expectation = expectation(description: "Handler called")
        let sut = AtomicTransition.spy { view, operation, context in
            XCTAssertIdentical(view, viewUsed)
            XCTAssertEqual(operation, operationUsed)
            XCTAssertIdentical(context, contextUsed)
            expectation.fulfill()
        }

        sut.prepare(viewUsed, for: operationUsed, in: contextUsed)
        wait(for: [expectation], timeout: 0)
    }
}

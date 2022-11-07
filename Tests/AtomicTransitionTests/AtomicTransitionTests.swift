@_spi(package) import AtomicTransition
import TestUtils

final class AtomicTransitionTests: XCTestCase {
    func testPrepare() {
        let animatorUsed = UnimplementedAnimator()
        let viewUsed = UnimplementedAnimatorTransientView()
        let operationUsed = AtomicTransition.Operation.random()
        let contextUsed = UnimplementedUIKitContext()

        let expectation = expectation(description: "Handler called")
        let sut = AtomicTransition.spy { animator, view, operation, context in
            XCTAssertIdentical(animator, animatorUsed)
            XCTAssertIdentical(view, viewUsed)
            XCTAssertEqual(operation, operationUsed)
            XCTAssertIdentical(context, contextUsed)
            expectation.fulfill()
        }

        sut.prepare(animatorUsed, or: viewUsed, for: operationUsed, in: contextUsed)
        wait(for: [expectation], timeout: 0)
    }
}

@_spi(package) import class Animator.AnimatorTransientView
@_spi(package) import AtomicTransition
import TestUtils

final class CustomTests: XCTestCase {
    func testWithTransientView() {
        let viewUsed = UnimplementedAnimatorTransientView()
        let operationUsed = AtomicTransition.Operation.random()
        let containerViewUsed = UIView()
        let contextUsed = MockedUIKitContext(containerView: containerViewUsed)

        let expectation = expectation(description: "Handler called")
        let sut = AtomicTransition.custom(withTransientView: { view, operation, container in
            XCTAssertIdentical(view, viewUsed)
            XCTAssertEqual(operation, operationUsed)
            XCTAssertIdentical(container, containerViewUsed)
            expectation.fulfill()
        })
        sut.prepare(viewUsed, for: operationUsed, in: contextUsed)
        wait(for: [expectation], timeout: 0)
    }
}

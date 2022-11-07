@_spi(package) import class Animator.AnimatorTransientView
@_spi(package) import AtomicTransition
import TestUtils

final class CustomTests: XCTestCase {
    func testWithAnimator() {
        let animatorUsed = UnimplementedAnimator()
        let uiViewUsed = UIView()
        let viewUsed = AnimatorTransientView(uiViewUsed)
        let operationUsed = AtomicTransition.Operation.random()
        let contextUsed = UnimplementedUIKitContext()

        let expectation = expectation(description: "Handler called")
        let sut = AtomicTransition.custom(withAnimator: { animator, uiView, operation, context in
            XCTAssertIdentical(animator, animatorUsed)
            XCTAssertIdentical(uiView, uiViewUsed)
            XCTAssertEqual(operation, operationUsed)
            XCTAssertIdentical(context, contextUsed)
            expectation.fulfill()
        })
        sut.prepare(animatorUsed, or: viewUsed, for: operationUsed, in: contextUsed)
        wait(for: [expectation], timeout: 0)
    }

    func testWithTransientView() {
        let animatorUsed = UnimplementedAnimator()
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
        sut.prepare(animatorUsed, or: viewUsed, for: operationUsed, in: contextUsed)
        wait(for: [expectation], timeout: 0)
    }
}

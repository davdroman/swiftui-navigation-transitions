@_spi(package) import Animator
@_spi(package) import AtomicTransition
import TestUtils
import XCTest

final class CustomTests: XCTestCase {
    func testWithAnimator() {
        let animatorUsed = UnimplementedAnimator()
        let uiViewUsed = UIView()
        let viewUsed = AtomicTransition.TransientView(uiViewUsed)
        let operationUsed = AtomicTransition.Operation.random()
        let contextUsed = UnimplementedUIKitContext()

        var handlerCalls = 0
        let sut = AtomicTransition.custom(withAnimator: { animator, uiView, operation, context in
            XCTAssertIdentical(animator, animatorUsed)
            XCTAssertIdentical(uiView, uiViewUsed)
            XCTAssertEqual(operation, operationUsed)
            XCTAssertIdentical(context, contextUsed)
            handlerCalls += 1
        })
        XCTAssertEqual(handlerCalls, 0)
        sut.prepare(animatorUsed, or: viewUsed, for: operationUsed, in: contextUsed)
        XCTAssertEqual(handlerCalls, 1)
    }

    func testWithTransientView() {
        let animatorUsed = UnimplementedAnimator()
        let viewUsed = UnimplementedAnimatorTransientView()
        let operationUsed = AtomicTransition.Operation.random()
        let containerViewUsed = UIView()
        let contextUsed = MockedUIKitContext(containerView: containerViewUsed)

        var handlerCalls = 0
        let sut = AtomicTransition.custom(withTransientView: { view, operation, container in
            XCTAssertIdentical(view, viewUsed)
            XCTAssertEqual(operation, operationUsed)
            XCTAssertIdentical(container, containerViewUsed)
            handlerCalls += 1
        })
        XCTAssertEqual(handlerCalls, 0)
        sut.prepare(animatorUsed, or: viewUsed, for: operationUsed, in: contextUsed)
        XCTAssertEqual(handlerCalls, 1)
    }
}

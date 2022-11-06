@_spi(package) import AtomicTransition
import TestUtils
import XCTest

final class AtomicTransitionTests: XCTestCase {
    func testPrepare() {
        let animatorUsed = UnimplementedAnimator()
        let viewUsed = UnimplementedAnimatorTransientView()
        let operationUsed = AtomicTransition.Operation.random()
        let contextUsed = UnimplementedUIKitContext()

        var handlerCalls = 0
        let sut = AtomicTransition.spy { animator, view, operation, context in
            XCTAssertIdentical(animator, animatorUsed)
            XCTAssertIdentical(view, viewUsed)
            XCTAssertEqual(operation, operationUsed)
            XCTAssertIdentical(context, contextUsed)
            handlerCalls += 1
        }

        XCTAssertEqual(handlerCalls, 0)
        sut.prepare(animatorUsed, or: viewUsed, for: operationUsed, in: contextUsed)
        XCTAssertEqual(handlerCalls, 1)
    }
}

@_spi(package) import AtomicTransition
import TestUtils
import XCTest

final class AsymmetricTests: XCTestCase {
    let animatorUsed = UnimplementedAnimator()
    let viewUsed = UnimplementedAnimatorTransientView()
    let contextUsed = UnimplementedUIKitContext()

    func testInsertion() {
        var handlerCalls = 0
        let sut = AtomicTransition.asymmetric(
            insertion: .spy { [self] animator, view, operation, context in
                XCTAssertIdentical(animator, animatorUsed)
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, .insertion)
                XCTAssertIdentical(context, contextUsed)
                handlerCalls += 1
            },
            removal: .spy { XCTFail() }
        )
        XCTAssertEqual(handlerCalls, 0)
        sut.prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)
        XCTAssertEqual(handlerCalls, 1)
    }

    func testRemoval() {
        var handlerCalls = 0
        let sut = AtomicTransition.asymmetric(
            insertion: .spy { XCTFail() },
            removal: .spy { [self] animator, view, operation, context in
                XCTAssertIdentical(animator, animatorUsed)
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, .removal)
                XCTAssertIdentical(context, contextUsed)
                handlerCalls += 1
            }
        )
        XCTAssertEqual(handlerCalls, 0)
        sut.prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)
        XCTAssertEqual(handlerCalls, 1)
    }
}

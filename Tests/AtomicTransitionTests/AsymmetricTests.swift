@_spi(package) import AtomicTransition
import TestUtils

final class AsymmetricTests: XCTestCase {
    let animatorUsed = UnimplementedAnimator()
    let viewUsed = UnimplementedAnimatorTransientView()
    let contextUsed = UnimplementedUIKitContext()

    func testInsertion() {
        let expectation = expectation(description: "Handler called")
        let sut = AtomicTransition.asymmetric(
            insertion: .spy { [self] animator, view, operation, context in
                XCTAssertIdentical(animator, animatorUsed)
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, .insertion)
                XCTAssertIdentical(context, contextUsed)
                expectation.fulfill()
            },
            removal: .spy { XCTFail() }
        )
        sut.prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)
        wait(for: [expectation], timeout: 0)
    }

    func testRemoval() {
        let expectation = expectation(description: "Handler called")
        let sut = AtomicTransition.asymmetric(
            insertion: .spy { XCTFail() },
            removal: .spy { [self] animator, view, operation, context in
                XCTAssertIdentical(animator, animatorUsed)
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, .removal)
                XCTAssertIdentical(context, contextUsed)
                expectation.fulfill()
            }
        )
        sut.prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)
        wait(for: [expectation], timeout: 0)
    }
}

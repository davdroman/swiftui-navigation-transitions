@_spi(package) import AtomicTransition
import TestUtils

final class AsymmetricTests: XCTestCase {
    let viewUsed = UnimplementedAnimatorTransientView()
    let contextUsed = UnimplementedUIKitContext()

    func testInsertion() {
        let expectation = expectation(description: "Handler called")
        let sut = AtomicTransition.asymmetric(
            insertion: .spy { [self] view, operation, context in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, .insertion)
                XCTAssertIdentical(context, contextUsed)
                expectation.fulfill()
            },
            removal: .spy { XCTFail() }
        )
        sut.prepare(viewUsed, for: .insertion, in: contextUsed)
        wait(for: [expectation], timeout: 0)
    }

    func testRemoval() {
        let expectation = expectation(description: "Handler called")
        let sut = AtomicTransition.asymmetric(
            insertion: .spy { XCTFail() },
            removal: .spy { [self] view, operation, context in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, .removal)
                XCTAssertIdentical(context, contextUsed)
                expectation.fulfill()
            }
        )
        sut.prepare(viewUsed, for: .removal, in: contextUsed)
        wait(for: [expectation], timeout: 0)
    }
}

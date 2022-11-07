@_spi(package) import AtomicTransition
import TestUtils

final class AsymmetricTests: XCTestCase {
    let viewUsed = UnimplementedAnimatorTransientView()
    let containerUsed = UIView()

    func testInsertion() {
        let expectation = expectation(description: "Handler called")
        let sut = Asymmetric(
            insertion: { Spy { expectation.fulfill() } },
            removal: { Spy { XCTFail() } }
        )
        sut.transition(viewUsed, for: .insertion, in: containerUsed)
        wait(for: [expectation], timeout: 0)
    }

    func testRemoval() {
        let expectation = expectation(description: "Handler called")
        let sut = Asymmetric(
            insertion: { Spy { XCTFail() } },
            removal: { Spy { expectation.fulfill() } }
        )
        sut.transition(viewUsed, for: .removal, in: containerUsed)
        wait(for: [expectation], timeout: 0)
    }
}

final class OnInsertionTests: XCTestCase {
    
}

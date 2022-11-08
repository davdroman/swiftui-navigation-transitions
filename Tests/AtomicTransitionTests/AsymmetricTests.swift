@_spi(package) import AtomicTransition
import TestUtils

final class AsymmetricTests: XCTestCase {
    func testInsertion() {
        let expectation = expectation(description: "Handler called")
        let sut = Asymmetric(
            insertion: { Spy { expectation.fulfill() } },
            removal: { Spy { XCTFail() } }
        )
        sut.transition(.unimplemented, for: .insertion, in: .unimplemented)
        wait(for: [expectation], timeout: 0)
    }

    func testRemoval() {
        let expectation = expectation(description: "Handler called")
        let sut = Asymmetric(
            insertion: { Spy { XCTFail() } },
            removal: { Spy { expectation.fulfill() } }
        )
        sut.transition(.unimplemented, for: .removal, in: .unimplemented)
        wait(for: [expectation], timeout: 0)
    }
}

final class OnInsertionTests: XCTestCase {
    func testInsertion() {
        let expectation = expectation(description: "Handler called")
        let sut = OnInsertion { Spy { expectation.fulfill() } }
        sut.transition(.unimplemented, for: .insertion, in: .unimplemented)
        wait(for: [expectation], timeout: 0)
    }

    func testRemoval() {
        let sut = OnInsertion { Spy { XCTFail() } }
        sut.transition(.unimplemented, for: .removal, in: .unimplemented)
    }
}

final class OnRemovalTests: XCTestCase {
    func testInsertion() {
        let sut = OnRemoval { Spy { XCTFail() } }
        sut.transition(.unimplemented, for: .insertion, in: .unimplemented)
    }

    func testRemoval() {
        let expectation = expectation(description: "Handler called")
        let sut = OnRemoval { Spy { expectation.fulfill() } }
        sut.transition(.unimplemented, for: .removal, in: .unimplemented)
        wait(for: [expectation], timeout: 0)
    }
}

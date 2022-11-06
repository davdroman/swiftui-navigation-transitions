@_spi(package) import AtomicTransition
import XCTest

final class AsymmetricTests: XCTestCase {
    func testInsertion() {
        var flag = false
        let sut = AtomicTransition.asymmetric(
            insertion: .spy { flag = true },
            removal: .spy {}
        )
        XCTAssertFalse(flag)
        sut.prepare(.unimplemented, or: .unimplemented, for: .insertion, in: .unimplemented)
        XCTAssertTrue(flag)
    }

    func testRemoval() {
        var flag = false
        let sut = AtomicTransition.asymmetric(
            insertion: .spy {},
            removal: .spy { flag = true }
        )
        XCTAssertFalse(flag)
        sut.prepare(.unimplemented, or: .unimplemented, for: .removal, in: .unimplemented)
        XCTAssertTrue(flag)
    }
}

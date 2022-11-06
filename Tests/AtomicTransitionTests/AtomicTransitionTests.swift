@_spi(package) @testable import AtomicTransition
import XCTest

final class AtomicTransitionTests: XCTestCase {
    func testPrepare() {
        var handlerCalled = false
        let sut = AtomicTransition { _, _, _, _ in
            handlerCalled = true
        }
        XCTAssertFalse(handlerCalled)
        sut.prepare(.unimplemented, or: .unimplemented, for: .insertion, in: .unimplemented)
        XCTAssertTrue(handlerCalled)
    }
}

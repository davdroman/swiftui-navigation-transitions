@_spi(package) import AtomicTransition
import XCTest

final class CombinedTests: XCTestCase {
    func test() {
        var sequence: [Character] = []
        let sut = AtomicTransition
            .spy { sequence.append("a") }
            .combined(with: .spy { sequence.append("b") })
            .combined(with: .spy { sequence.append("c") })
            .combined(with: .spy { sequence.append("d") })
        XCTAssertEqual(sequence, [])
        sut.prepare(.unimplemented, or: .unimplemented, for: .insertion, in: .unimplemented)
        XCTAssertEqual(sequence, ["a", "b", "c", "d"])
    }
}

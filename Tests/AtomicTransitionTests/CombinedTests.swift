@_spi(package) import AtomicTransition
import TestUtils

final class CombinedTests: XCTestCase {
    func test() {
        let viewUsed = UnimplementedAnimatorTransientView()
        let operationUsed = AtomicTransition.Operation.random()
        let contextUsed = UnimplementedUIKitContext()

        var sequence: [Character] = []
        let sut = AtomicTransition
            .spy { view, operation, context in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(context, contextUsed)
                sequence.append("a")
            }
            .combined(with: .spy { view, operation, context in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(context, contextUsed)
                sequence.append("b")
            })
            .combined(with: .spy { view, operation, context in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(context, contextUsed)
                sequence.append("c")
            })
            .combined(with: .spy { view, operation, context in
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(context, contextUsed)
                sequence.append("d")
            })
        XCTAssertEqual(sequence, [])
        sut.prepare(viewUsed, for: operationUsed, in: contextUsed)
        XCTAssertEqual(sequence, ["a", "b", "c", "d"])
    }
}

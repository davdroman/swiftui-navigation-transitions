@_spi(package) import Animator
@_spi(package) import AtomicTransition
import XCTest

final class CombinedTests: XCTestCase {
    func test() {
        let animatorUsed = UnimplementedAnimator()
        let viewUsed = UnimplementedAnimatorTransientView()
        let operationUsed = AtomicTransition.Operation.random()
        let contextUsed = UnimplementedUIKitContext()

        var sequence: [Character] = []
        let sut = AtomicTransition
            .spy { animator, view, operation, context in
                XCTAssertIdentical(animator, animatorUsed)
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(context, contextUsed)
                sequence.append("a")
            }
            .combined(with: .spy { animator, view, operation, context in
                XCTAssertIdentical(animator, animatorUsed)
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(context, contextUsed)
                sequence.append("b")
            })
            .combined(with: .spy { animator, view, operation, context in
                XCTAssertIdentical(animator, animatorUsed)
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(context, contextUsed)
                sequence.append("c")
            })
            .combined(with: .spy { animator, view, operation, context in
                XCTAssertIdentical(animator, animatorUsed)
                XCTAssertIdentical(view, viewUsed)
                XCTAssertEqual(operation, operationUsed)
                XCTAssertIdentical(context, contextUsed)
                sequence.append("d")
            })
        XCTAssertEqual(sequence, [])
        sut.prepare(animatorUsed, or: viewUsed, for: operationUsed, in: contextUsed)
        XCTAssertEqual(sequence, ["a", "b", "c", "d"])
    }
}

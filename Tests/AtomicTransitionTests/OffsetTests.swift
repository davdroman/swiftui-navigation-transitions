@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import TestUtils

final class OffsetTests: XCTestCase {
    let viewUsed = AnimatorTransientView(UIView())
    let properties = AnimatorTransientViewProperties(alpha: 1, transform: .identity)
    let containerUsed = UIView()

    func testInsertion() {
        Offset(x: 100, y: 200).transition(viewUsed, for: .insertion, in: containerUsed)

        var initial = properties
        initial.transform = .identity.translatedBy(x: 100, y: 200)
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testRemoval() {
        Offset(x: 100, y: 200).transition(viewUsed, for: .removal, in: containerUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 100, y: 200)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testConveniences() {
        XCTAssertEqual(Offset(x: 1, y: 0), Offset(x: 1))
        XCTAssertEqual(Offset(x: 0, y: 1), Offset(y: 1))
        XCTAssertEqual(Offset(x: 1, y: 2), Offset(.init(width: 1, height: 2)))
    }
}

@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import TestUtils

final class ScaleTests: XCTestCase {
    let viewUsed = AnimatorTransientView(UIView())
    let properties = AnimatorTransientViewProperties(
        alpha: 1,
        transform: .identity,
        zPosition: 0
    )
    let containerUsed = UIView()

    func testInsertion() {
        Scale(0.5).transition(viewUsed, for: .insertion, in: containerUsed)

        var initial = properties
        initial.transform.scale(0.5)
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform.rotate(by: 0, z: 1)
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testRemoval() {
        Scale(0.5).transition(viewUsed, for: .removal, in: containerUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform.scale(0.5)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform.rotate(by: 0, z: 1)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testConveniences() {
        XCTAssertEqual(Scale(), Scale(.leastNonzeroMagnitude))
    }
}

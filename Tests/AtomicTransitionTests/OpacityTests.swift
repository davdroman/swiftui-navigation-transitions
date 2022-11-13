@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import TestUtils

final class OpacityTests: XCTestCase {
    let viewUsed = AnimatorTransientView(UIView())
    let properties = AnimatorTransientViewProperties(
        alpha: 1,
        layer: .init(
            transform: CATransform3DIdentity,
            zPosition: 0
        ),
        transform: .identity
    )
    let containerUsed = UIView()

    func testInsertion() {
        Opacity().transition(viewUsed, for: .insertion, in: containerUsed)

        var initial = properties
        initial.alpha = 0
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.alpha = 1
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testRemoval() {
        Opacity().transition(viewUsed, for: .removal, in: containerUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.alpha = 0
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.alpha = 1
        XCTAssertNoDifference(viewUsed.completion, completion)
    }
}

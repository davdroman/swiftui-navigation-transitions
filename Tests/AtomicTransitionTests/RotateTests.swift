@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import TestUtils

final class RotateTests: XCTestCase {
    let animatorUsed = UnimplementedAnimator()
    let viewUsed = AnimatorTransientView(UIView())
    let properties = AnimatorTransientViewProperties(alpha: 1, transform: .identity)
    let contextUsed = MockedUIKitContext(containerView: UIView())

    func testInsertion() {
        AtomicTransition.rotate(.radians(.pi)).prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)

        var initial = properties
        initial.transform = .identity.rotated(by: .pi)
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.rotated(by: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testRemoval() {
        AtomicTransition.rotate(.radians(.pi)).prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.rotated(by: .pi)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform = .identity.rotated(by: 0)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }
}

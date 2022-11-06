@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import CustomDump
import XCTest

final class OpacityTests: XCTestCase {
    let animatorUsed = UnimplementedAnimator()
    let uiViewUsed = UIView()
    lazy var viewUsed = AnimatorTransientView(uiViewUsed)
    let properties = AnimatorTransientViewProperties(alpha: 1, transform: .identity)
    lazy var contextUsed = MockedContext(containerView: UIView())

    func testInsertion() {
        AtomicTransition.opacity.prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)

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
        AtomicTransition.opacity.prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)

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
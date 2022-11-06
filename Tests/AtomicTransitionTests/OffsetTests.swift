@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import TestUtils
import XCTest

final class OffsetTests: XCTestCase {
    let animatorUsed = UnimplementedAnimator()
    let viewUsed = AnimatorTransientView(UIView())
    let properties = AnimatorTransientViewProperties(alpha: 1, transform: .identity)
    let contextUsed = MockedUIKitContext(containerView: UIView())

    func testInsertion() {
        AtomicTransition.offset(x: 100, y: 200).prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)

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
        AtomicTransition.offset(x: 100, y: 200).prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 100, y: 200)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    // TODO: assert for (x, y | x | y) conveniences equality when this is done:
    // https://github.com/davdroman/swiftui-navigation-transitions/discussions/6
    // func testConveniences() {}
}

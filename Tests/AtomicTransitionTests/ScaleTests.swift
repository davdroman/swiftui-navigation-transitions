@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import CustomDump
import SwiftUI
import XCTest

final class ScaleTests: XCTestCase {
    let animatorUsed = UnimplementedAnimator()
    let viewUsed = AnimatorTransientView(UIView())
    let properties = AnimatorTransientViewProperties(alpha: 1, transform: .identity)
    let contextUsed = MockedContext(containerView: UIView())

    func testInsertion() {
        AtomicTransition.scale(0.5).prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)

        var initial = properties
        initial.transform = .identity.scaledBy(x: 0.5, y: 0.5)
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.rotated(by: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testRemoval() {
        AtomicTransition.scale(0.5).prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.scaledBy(x: 0.5, y: 0.5)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform = .identity.rotated(by: 0)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    // TODO: assert for (x, y | x | y) conveniences equality when this is done:
    // https://github.com/davdroman/swiftui-navigation-transitions/discussions/6
    // func testConveniences() {}
}

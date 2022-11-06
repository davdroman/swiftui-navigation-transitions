@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import CustomDump
import SwiftUI
import XCTest

final class RotateTests: XCTestCase {
    let animatorUsed = UnimplementedAnimator()
    let uiViewUsed = UIView()
    lazy var viewUsed = AnimatorTransientView(uiViewUsed)
    let properties = AnimatorTransientViewProperties(alpha: 1, transform: .identity)
    lazy var contextUsed = MockedContext(containerView: UIView())

    func testInsertion() {
        let angle = Angle(degrees: 90)
        AtomicTransition.rotate(angle).prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)

        var initial = properties
        initial.transform = .identity.rotated(by: angle.radians)
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.rotated(by: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testRemoval() {
        let angle = Angle(degrees: 90)
        AtomicTransition.rotate(angle).prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.rotated(by: angle.radians)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform = .identity.rotated(by: 0)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }
}

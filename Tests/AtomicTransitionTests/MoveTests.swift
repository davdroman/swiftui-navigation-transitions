@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import CustomDump
import XCTest

final class MoveTests: XCTestCase {
    let animatorUsed = UnimplementedAnimator()
    let viewUsed = AnimatorTransientView(UIView())
    let properties = AnimatorTransientViewProperties(alpha: 1, transform: .identity)
    let containerUsed: UIView = {
        let _containerUsed = UIView()
        _containerUsed.frame.size = .init(width: 100, height: 200)
        return _containerUsed
    }()
    lazy var contextUsed = MockedUIKitContext(containerView: containerUsed)
}

extension MoveTests {
    func testInitialState() {
        XCTAssertEqual(viewUsed.initial, properties)
        XCTAssertEqual(viewUsed.animation, properties)
        XCTAssertEqual(viewUsed.completion, properties)
    }
}

extension MoveTests {
    func testTopInsertion() {
        AtomicTransition.move(edge: .top).prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)

        var initial = properties
        initial.transform = .identity.translatedBy(x: 0, y: -200)
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testLeadingInsertion() {
        AtomicTransition.move(edge: .leading).prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)

        var initial = properties
        initial.transform = .identity.translatedBy(x: -100, y: 0)
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testTrailingInsertion() {
        AtomicTransition.move(edge: .trailing).prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)

        var initial = properties
        initial.transform = .identity.translatedBy(x: 100, y: 0)
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testBottomInsertion() {
        AtomicTransition.move(edge: .bottom).prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)

        var initial = properties
        initial.transform = .identity.translatedBy(x: 0, y: 200)
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        let completion = properties
        XCTAssertNoDifference(viewUsed.completion, completion)
    }
}

extension MoveTests {
    func testTopRemoval() {
        AtomicTransition.move(edge: .top).prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 0, y: -200)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testLeadingRemoval() {
        AtomicTransition.move(edge: .leading).prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: -100, y: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testTrailingRemoval() {
        AtomicTransition.move(edge: .trailing).prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 100, y: 0)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }

    func testBottomRemoval() {
        AtomicTransition.move(edge: .bottom).prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)

        let initial = properties
        XCTAssertNoDifference(viewUsed.initial, initial)

        var animation = properties
        animation.transform = .identity.translatedBy(x: 0, y: 200)
        XCTAssertNoDifference(viewUsed.animation, animation)

        var completion = properties
        completion.transform = .identity.translatedBy(x: 0, y: 0)
        XCTAssertNoDifference(viewUsed.completion, completion)
    }
}

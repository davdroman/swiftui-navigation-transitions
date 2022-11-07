@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import TestUtils

final class ZPositionTests: XCTestCase {
    let uiViewUsed = UIView()
    lazy var viewUsed = AnimatorTransientView(uiViewUsed)
    let properties = AnimatorTransientViewProperties(alpha: 1, transform: .identity)
    let anotherUIViewA = UIView()
    let anotherUIViewB = UIView()
    let operation = AtomicTransition.Operation.random()
    lazy var containerView: UIView = {
        let _containerView = UIView()
        _containerView.addSubview(anotherUIViewA)
        _containerView.addSubview(uiViewUsed)
        _containerView.addSubview(anotherUIViewB)
        return _containerView
    }()
    lazy var contextUsed = MockedUIKitContext(containerView: containerView)

    func testInitialState() {
        XCTAssertIdentical(containerView.subviews[0], anotherUIViewA)
        XCTAssertIdentical(containerView.subviews[1], uiViewUsed)
        XCTAssertIdentical(containerView.subviews[2], anotherUIViewB)
    }

    func testFront() {
        AtomicTransition.zPosition(.front).prepare(viewUsed, for: operation, in: contextUsed)

        XCTAssertIdentical(containerView.subviews[0], anotherUIViewA)
        XCTAssertIdentical(containerView.subviews[1], anotherUIViewB)
        XCTAssertIdentical(containerView.subviews[2], uiViewUsed)
    }

    func testBack() {
        AtomicTransition.zPosition(.back).prepare(viewUsed, for: operation, in: contextUsed)

        XCTAssertIdentical(containerView.subviews[0], uiViewUsed)
        XCTAssertIdentical(containerView.subviews[1], anotherUIViewA)
        XCTAssertIdentical(containerView.subviews[2], anotherUIViewB)
    }

    // TODO: assert for (x, y | x | y) conveniences equality when this is done:
    // https://github.com/davdroman/swiftui-navigation-transitions/discussions/6
    // func testConveniences() {}
}

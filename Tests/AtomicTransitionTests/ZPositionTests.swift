@_spi(package) @testable import Animator
@_spi(package) import AtomicTransition
import TestUtils

final class ZPositionTests: XCTestCase {
    let uiViewUsed = UIView()
    lazy var viewUsed = AnimatorTransientView(uiViewUsed)
    let properties = AnimatorTransientViewProperties(
        alpha: 1,
        transform: .identity,
        layer: .init(
            zPosition: 0
        )
    )
    let anotherUIViewA = UIView()
    let anotherUIViewB = UIView()
    lazy var containerView: UIView = {
        let _containerView = UIView()
        _containerView.addSubview(anotherUIViewA)
        _containerView.addSubview(uiViewUsed)
        _containerView.addSubview(anotherUIViewB)
        return _containerView
    }()

    func testInitialState() {
        XCTAssertIdentical(containerView.subviews[0], anotherUIViewA)
        XCTAssertIdentical(containerView.subviews[1], uiViewUsed)
        XCTAssertIdentical(containerView.subviews[2], anotherUIViewB)
    }

    func testFront() {
        BringToFront().transition(viewUsed, for: .random(), in: containerView)

        XCTAssertIdentical(containerView.subviews[0], anotherUIViewA)
        XCTAssertIdentical(containerView.subviews[1], anotherUIViewB)
        XCTAssertIdentical(containerView.subviews[2], uiViewUsed)
    }

    func testBack() {
        SendToBack().transition(viewUsed, for: .random(), in: containerView)

        XCTAssertIdentical(containerView.subviews[0], uiViewUsed)
        XCTAssertIdentical(containerView.subviews[1], anotherUIViewA)
        XCTAssertIdentical(containerView.subviews[2], anotherUIViewB)
    }
}

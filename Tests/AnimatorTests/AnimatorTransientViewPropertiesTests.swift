@_spi(package) @testable import Animator
import TestUtils

final class AnimatorTransientViewPropertiesTests: XCTestCase {
    var sut = AnimatorTransientView.Properties(
        alpha: 0.5,
        transform: .init(.init()),
        zPosition: 15
    )
}

extension AnimatorTransientViewPropertiesTests {
    func testAssignToUIView() {
        let view = UIView()

        XCTAssertEqual(view.alpha, 0.5)
        XCTAssert(CATransform3DEqualToTransform(view.transform3D, CATransform3DIdentity))

        sut.assignToUIView(view)

        XCTAssertEqual(view.alpha, 0.5)
        XCTAssert(CATransform3DEqualToTransform(view.transform3D, CATransform3DIdentity))

//        sut.alpha = 0.3
//        XCTAssertEqual(sut.$alpha, 0.3)
//        XCTAssertEqual(sut.alpha, 0.3)
//        sut.transform = .identity.rotated(by: .pi)
//        XCTAssertEqual(sut.$transform, .identity.rotated(by: .pi))
//        XCTAssertEqual(sut.transform, .identity.rotated(by: .pi))
    }
}

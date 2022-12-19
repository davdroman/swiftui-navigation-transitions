@_spi(package) @testable import Animator
import TestUtils

final class AnimatorTransientViewTests: XCTestCase {}

extension AnimatorTransientViewTests {
	func testInit() {
		let uiView = UIView()
		uiView.alpha = 0.5
		uiView.frame = .init(x: 10, y: 20, width: 30, height: 40)
		uiView.transform3D = .identity.translated(x: 50, y: 60, z: 0).scaled(4).rotated(by: .pi, x: 0, y: 0, z: 1)
		uiView.layer.zPosition = 15

		let sut = AnimatorTransientView(uiView)

		XCTAssertEqual(sut.alpha, 0.5)
		XCTAssertEqual(sut.bounds, .init(x: 0, y: 0, width: 30, height: 40))
		XCTAssertEqual(sut.frame.origin.x, 15, accuracy: 0.000001)
		XCTAssertEqual(sut.frame.origin.y, 20, accuracy: 0.000001)
		XCTAssertEqual(sut.frame.size.width, 120, accuracy: 0.000001)
		XCTAssertEqual(sut.frame.size.height, 160, accuracy: 0.000001)
		XCTAssertEqual(sut.transform3D, .identity.translated(x: 50, y: 60, z: 0).scaled(4).rotated(by: .pi, x: 0, y: 0, z: 1))

		let expectedProperties = AnimatorTransientView.Properties(
			alpha: 0.5,
			transform: .init(.identity.translated(x: 50, y: 60, z: 0).scaled(4).rotated(by: .pi, x: 0, y: 0, z: 1)),
			zPosition: 15
		)

		XCTAssertEqual(sut.initial, expectedProperties)
		XCTAssertEqual(sut.animation, expectedProperties)
		XCTAssertEqual(sut.completion, expectedProperties)
	}
}

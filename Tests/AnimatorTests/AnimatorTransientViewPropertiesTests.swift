@testable import Animator
import TestUtils

final class AnimatorTransientViewPropertiesTests: XCTestCase {}

extension AnimatorTransientViewPropertiesTests {
	func testAssignToUIView() {
		let view = UIView()
		XCTAssertEqual(view.alpha, 1)
		XCTAssertEqual(view.transform3D, .identity)
		XCTAssertEqual(view.layer.zPosition, 0)

		var sut = AnimatorTransientView.Properties(of: view)

		sut.alpha = 0.5
		sut.transform = .init(.identity.scaled(5))
		sut.zPosition = 15

		sut.assignToUIView(view, force: false)
		XCTAssertEqual(view.alpha, 0.5)
		XCTAssertEqual(view.transform3D, .identity.scaled(5))
		XCTAssertEqual(view.layer.zPosition, 15)
	}

	func testForceAssignToUIView() {
		let view = UIView()
		view.transform = .identity.scaledBy(x: 5, y: 5)
		view.layer.zPosition = 15
		XCTAssertEqual(view.alpha, 1)
		XCTAssertEqual(view.transform, .identity.scaledBy(x: 5, y: 5))
		XCTAssertEqual(view.layer.zPosition, 15)

		var sut = AnimatorTransientView.Properties.default
		sut.alpha = 0.5

		sut.assignToUIView(view, force: true)
		XCTAssertEqual(view.alpha, 0.5)
		XCTAssertEqual(view.transform3D, .identity)
		XCTAssertEqual(view.layer.zPosition, 0)
	}
}

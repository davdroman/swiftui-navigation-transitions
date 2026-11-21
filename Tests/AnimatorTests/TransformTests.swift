@testable import Animator
import Testing
import UIKit

@MainActor
struct TransformTests {
	@Test
	func `mutations apply in order to the underlying transform`() {
		var sut = Transform.identity
		sut.translate(x: 10, y: 20, z: 30)
		sut.scale(x: 2, y: 3, z: 4)
		sut.scale(5)
		sut.rotate(by: .pi / 2, x: 0, y: 1, z: 0)

		var expected = CATransform3DIdentity
		expected = CATransform3DTranslate(expected, 10, 20, 30)
		expected = CATransform3DScale(expected, 2, 3, 4)
		expected = CATransform3DScale(expected, 5, 5, 5)
		expected = CATransform3DRotate(expected, .pi / 2, 0, 1, 0)
		#expect(sut == Transform(expected))
	}

	@Test
	func `concatenation applies the other transform after this one`() {
		var lhs = Transform.identity
		lhs.translate(x: 10)
		var rhs = Transform.identity
		rhs.scale(2)

		let expected = CATransform3DConcat(
			CATransform3DMakeTranslation(10, 0, 0),
			CATransform3DMakeScale(2, 2, 2),
		)
		#expect(lhs.concatenated(with: rhs) == Transform(expected))
	}

	@Test
	func `matrix entries are readable and writable`() {
		var sut = Transform.identity
		sut.m34 = -0.002

		#expect(sut.m34 == -0.002)
		#expect(sut.m11 == 1)
	}

	@Test
	func `affine transforms assign to the view's 2D transform`() {
		let view = UIView()
		var properties = AnimatorTransientViewProperties(of: view)
		properties.transform.translate(x: 10, y: 20)
		properties.transform.scale(x: 2, y: 3)

		properties.assignToUIView(view, force: false)

		#expect(view.transform == CGAffineTransform(translationX: 10, y: 20).scaledBy(x: 2, y: 3))
	}

	@Test
	func `3D transforms assign to the view's 3D transform`() {
		let view = UIView()
		var properties = AnimatorTransientViewProperties(of: view)
		properties.transform.m34 = -0.002
		properties.transform.rotate(by: .pi / 4, y: 1)

		properties.assignToUIView(view, force: false)

		var expected = CATransform3DIdentity
		expected.m34 = -0.002
		expected = CATransform3DRotate(expected, .pi / 4, 0, 1, 0)
		#expect(CATransform3DEqualToTransform(view.transform3D, expected))
	}
}

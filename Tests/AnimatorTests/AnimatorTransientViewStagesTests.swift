@testable import Animator
import Testing
import UIKit

@MainActor
struct AnimatorTransientViewStagesTests {
	@Test
	func `setting a stage writes only the properties it changed`() {
		let uiView = UIView()
		let sut = AnimatorTransientView(uiView)
		sut.animation.alpha = 0.5
		uiView.layer.zPosition = 3
		uiView.transform = CGAffineTransform(scaleX: 2, y: 2)

		sut.setUIViewProperties(to: \.animation)

		#expect(uiView.alpha == 0.5)
		#expect(uiView.layer.zPosition == 3)
		#expect(uiView.transform == CGAffineTransform(scaleX: 2, y: 2))
	}

	@Test
	func `forcing a stage writes every property`() {
		let uiView = UIView()
		let sut = AnimatorTransientView(uiView)
		sut.completion.alpha = 0.5
		uiView.layer.zPosition = 3
		uiView.transform = CGAffineTransform(scaleX: 2, y: 2)

		sut.setUIViewProperties(to: \.completion, force: true)

		#expect(uiView.alpha == 0.5)
		#expect(uiView.layer.zPosition == 0)
		#expect(uiView.transform == .identity)
	}

	@Test
	func `resetting restores the default properties`() {
		let uiView = UIView()
		let sut = AnimatorTransientView(uiView)
		uiView.alpha = 0.5
		uiView.layer.zPosition = 3
		uiView.transform3D = CATransform3DMakeRotation(.pi / 4, 0, 1, 0)

		sut.resetUIViewProperties()

		#expect(uiView.alpha == 1)
		#expect(uiView.layer.zPosition == 0)
		#expect(CATransform3DIsIdentity(uiView.transform3D))
	}
}

import Animator
import Testing
import UIKit

@MainActor
struct AnimatorTests {
	@Test
	func `property animators run added animations and completions`() {
		let view = UIView()
		let propertyAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)
		let sut: any Animator = propertyAnimator
		var finalPosition: UIViewAnimatingPosition? = nil

		sut.addAnimations { view.alpha = 0.5 }
		sut.addCompletion { finalPosition = $0 }
		propertyAnimator.startAnimation()
		propertyAnimator.stopAnimation(false)
		propertyAnimator.finishAnimation(at: .end)

		#expect(view.alpha == 0.5)
		#expect(finalPosition == .end)
	}
}

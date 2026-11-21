import Testing
import UIKit
@testable import UIKitNavigationTransitions

@MainActor
struct AnimatorProviderTests {
	@Test
	func `push inserts the destination above the source`() {
		let context = TestTransitionContext()

		_ = provider(.slide, for: .push).interruptibleAnimator(using: context)

		#expect(context.containerView.subviews == [context.from.view, context.to.view])
	}

	@Test
	func `pop inserts the destination below the source`() {
		let context = TestTransitionContext()

		_ = provider(.slide, for: .pop).interruptibleAnimator(using: context)

		#expect(context.containerView.subviews == [context.to.view, context.from.view])
	}

	@Test
	func `views take each stage's properties as the transition runs`() {
		let context = TestTransitionContext()
		let animator = provider(.stages, for: .push).interruptibleAnimator(using: context)

		#expect(context.from.view.alpha == 0.25)
		#expect(context.to.view.alpha == 0.25)

		animator.startAnimation()
		#expect(context.from.view.alpha == 0.5)
		#expect(context.to.view.alpha == 0.5)

		animator.stopAnimation(false)
		animator.finishAnimation(at: .end)
		#expect(context.from.view.alpha == 0.75)
		#expect(context.to.view.alpha == 0.75)
		#expect(context.completions == [true])
	}

	@Test
	func `cancelling resets the views and completes without finishing`() {
		let context = TestTransitionContext()
		let animator = provider(.stages, for: .push).interruptibleAnimator(using: context)

		animator.startAnimation()
		context.transitionWasCancelled = true
		animator.stopAnimation(false)
		animator.finishAnimation(at: .start)

		#expect(context.from.view.alpha == 1)
		#expect(context.to.view.alpha == 1)
		#expect(context.completions == [false])
	}

	@Test
	func `views ignore interaction until the transition ends`() {
		let context = TestTransitionContext()
		let animator = provider(.slide, for: .push).interruptibleAnimator(using: context)

		#expect(!context.from.view.isUserInteractionEnabled)
		#expect(!context.to.view.isUserInteractionEnabled)

		animator.startAnimation()
		animator.stopAnimation(false)
		animator.finishAnimation(at: .end)

		#expect(context.from.view.isUserInteractionEnabled)
		#expect(context.to.view.isUserInteractionEnabled)
	}

	@Test
	func `a transition context gets one animator until the transition ends`() {
		let context = TestTransitionContext()
		let sut = provider(.slide, for: .push)

		let animator = sut.interruptibleAnimator(using: context)
		#expect(sut.interruptibleAnimator(using: context) === animator)
		#expect(sut.interruptibleAnimator(using: TestTransitionContext()) !== animator)

		sut.animationEnded(true)
		#expect(sut.interruptibleAnimator(using: context) !== animator)
	}

	@Test
	func `primitive transitions receive the animator, operation, and context`() {
		let context = TestTransitionContext()
		var calls: [(animator: AnyObject, operation: NavigationTransitionOperation, context: AnyObject)] = []
		let transition = CustomNavigationTransition(PrimitiveSpy { animator, operation, context in
			calls.append((animator as AnyObject, operation, context as AnyObject))
		})

		let animator = provider(transition, for: .pop).interruptibleAnimator(using: context)

		#expect(calls.count == 1)
		#expect(calls.first?.animator === animator)
		#expect(calls.first?.operation == .pop)
		#expect(calls.first?.context === context)
	}

	private func provider(
		_ transition: CustomNavigationTransition,
		for operation: NavigationTransitionOperation,
	) -> NavigationTransitionAnimatorProvider {
		NavigationTransitionAnimatorProvider(transition: transition, animation: .linear, operation: operation)
	}
}

@MainActor
extension CustomNavigationTransition {
	/// Sets the alpha of both views to 0.25 initially, 0.5 when animating, and 0.75 on completion.
	fileprivate static var stages: Self {
		.init(Stages())
	}
}

private struct Stages: NavigationTransitionProtocol {
	func transition(
		from fromView: TransientView,
		to toView: TransientView,
		for operation: TransitionOperation,
		in container: Container,
	) {
		for view in [fromView, toView] {
			view.initial.alpha = 0.25
			view.animation.alpha = 0.5
			view.completion.alpha = 0.75
		}
	}
}

private struct PrimitiveSpy: PrimitiveNavigationTransition {
	let handler: @MainActor (any Animator, TransitionOperation, any Context) -> Void

	func transition(with animator: any Animator, for operation: TransitionOperation, in context: any Context) {
		handler(animator, operation, context)
	}
}

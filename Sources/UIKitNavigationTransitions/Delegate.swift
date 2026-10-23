import Animation
import Animator
import Foundation
import NavigationTransition
import UIKit

final class NavigationTransitionDelegate: NSObject, UINavigationControllerDelegate {
	var transition: CustomNavigationTransition
	private weak var baseDelegate: (any UINavigationControllerDelegate)? = nil
	var interactionController: UIPercentDrivenInteractiveTransition? = nil

	init(transition: CustomNavigationTransition, baseDelegate: (any UINavigationControllerDelegate)?) {
		self.transition = transition
		self.baseDelegate = baseDelegate
	}

	func navigationController(
		_ navigationController: UINavigationController,
		willShow viewController: UIViewController,
		animated: Bool,
	) {
		baseDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
	}

	func navigationController(
		_ navigationController: UINavigationController,
		didShow viewController: UIViewController,
		animated: Bool,
	) {
		baseDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
	}

	func navigationController(
		_ navigationController: UINavigationController,
		interactionControllerFor animationController: any UIViewControllerAnimatedTransitioning,
	) -> (any UIViewControllerInteractiveTransitioning)? {
		if !transition.isDefault {
			interactionController
		} else {
			nil
		}
	}

	func navigationController(
		_ navigationController: UINavigationController,
		animationControllerFor operation: UINavigationController.Operation,
		from fromVC: UIViewController,
		to toVC: UIViewController,
	) -> (any UIViewControllerAnimatedTransitioning)? {
		if
			!transition.isDefault,
			let animation = transition.animation,
			let operation = NavigationTransitionOperation(operation)
		{
			NavigationTransitionAnimatorProvider(
				transition: transition,
				animation: animation,
				operation: operation,
			)
		} else {
			nil
		}
	}
}

final class NavigationTransitionAnimatorProvider: NSObject, UIViewControllerAnimatedTransitioning {
	let transition: CustomNavigationTransition
	let animation: Animation
	let operation: NavigationTransitionOperation

	init(transition: CustomNavigationTransition, animation: Animation, operation: NavigationTransitionOperation) {
		self.transition = transition
		self.animation = animation
		self.operation = operation
	}

	func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
		animation.duration
	}

	func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
		transitionAnimator(for: transitionContext).startAnimation()
	}

	func interruptibleAnimator(
		using transitionContext: any UIViewControllerContextTransitioning,
	) -> any UIViewImplicitlyAnimating {
		transitionAnimator(for: transitionContext)
	}

	func animationEnded(_ transitionCompleted: Bool) {
		cachedAnimators.removeAll(keepingCapacity: true)
	}

	private var cachedAnimators: [ObjectIdentifier: UIViewPropertyAnimator] = .init(minimumCapacity: 1)

	private func transitionAnimator(
		for transitionContext: any UIViewControllerContextTransitioning,
	) -> UIViewPropertyAnimator {
		if let cached = cachedAnimators[ObjectIdentifier(transitionContext)] {
			return cached
		}
		let animator = UIViewPropertyAnimator(
			duration: transitionDuration(using: transitionContext),
			timingParameters: animation.timingParameters,
		)
		cachedAnimators[ObjectIdentifier(transitionContext)] = animator

		let container = transitionContext.containerView
		guard
			let fromUIView = transitionContext.view(forKey: .from),
			let toUIView = transitionContext.view(forKey: .to)
		else {
			return animator
		}

		fromUIView.isUserInteractionEnabled = false
		toUIView.isUserInteractionEnabled = false

		switch transition.handler {
		case let .transient(handler):
			if
				let (fromView, toView) = transientViews(
					for: handler,
					animator: animator,
					context: (container, fromUIView, toUIView),
				)
			{
				for view in [fromView, toView] {
					view.setUIViewProperties(to: \.initial)
					animator.addAnimations { view.setUIViewProperties(to: \.animation) }
					animator.addCompletion { _ in
						if transitionContext.transitionWasCancelled {
							view.resetUIViewProperties()
						} else {
							view.setUIViewProperties(to: \.completion)
						}
					}
				}
			}
		case let .primitive(handler):
			handler(animator, operation, transitionContext)
		}

		let diagnosticVariant = ProcessInfo.processInfo.environment["NAVIGATION_AB_VARIANT"]
		animator.addCompletion { _ in
			@MainActor func record(_ event: String) {
				guard diagnosticVariant == "baseline" || diagnosticVariant == "no-reattach" else { return }
				let entry = "\(ProcessInfo.processInfo.systemUptime) variant=\(diagnosticVariant ?? "unset") \(event) cancelled=\(transitionContext.transitionWasCancelled) from=\(diagnosticView(fromUIView)) to=\(diagnosticView(toUIView))"
				NSLog("[NAV-AB-LIB] %@", entry)
				var entries = UserDefaults.standard.stringArray(forKey: "NavigationABLibraryTrace") ?? []
				entries.append(entry)
				UserDefaults.standard.set(entries, forKey: "NavigationABLibraryTrace")
			}
			record("beforeCompleteTransition")
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			record("afterCompleteTransition")

			fromUIView.isUserInteractionEnabled = true
			toUIView.isUserInteractionEnabled = true

			// On iOS 16, cancelling swipe-back can leave the surviving view unresponsive;
			// detaching and reattaching nudges it back into responding to interaction.
			// Retain that workaround here, but avoid it on newer OS versions because
			// reattachment resigns the first responder and dismisses the keyboard.
			if #unavailable(iOS 17, tvOS 17, visionOS 1) {
				if diagnosticVariant == "no-reattach" {
					record("candidateSkippedReattachment")
					return
				}
				record("beforeDetach")
				if transitionContext.transitionWasCancelled {
					fromUIView.removeFromSuperview()
					record("afterDetach")
					container.addSubview(fromUIView)
				} else {
					toUIView.removeFromSuperview()
					record("afterDetach")
					container.addSubview(toUIView)
				}
				record("afterReattach")
			}
		}

		return animator
	}

	private func transientViews(
		for handler: CustomNavigationTransition.TransientHandler,
		animator: any Animator,
		context: (container: UIView, fromUIView: UIView, toUIView: UIView),
	) -> (fromView: AnimatorTransientView, toView: AnimatorTransientView)? {
		let (container, fromUIView, toUIView) = context

		switch operation {
		case .push:
			container.insertSubview(toUIView, aboveSubview: fromUIView)
		case .pop:
			container.insertSubview(toUIView, belowSubview: fromUIView)
		}

		let fromView = AnimatorTransientView(fromUIView)
		let toView = AnimatorTransientView(toUIView)

		handler(fromView, toView, operation, container)

		return (fromView, toView)
	}
}

@MainActor
private func diagnosticView(_ view: UIView) -> String {
	func focused(_ view: UIView) -> UIView? {
		if view.isFirstResponder { return view }
		return view.subviews.lazy.compactMap { focused($0) }.first
	}
	return "view=\(ObjectIdentifier(view)) super=\(String(describing: view.superview.map(ObjectIdentifier.init))) window=\(view.window != nil) interactive=\(view.isUserInteractionEnabled) responder=\(String(describing: focused(view)))"
}

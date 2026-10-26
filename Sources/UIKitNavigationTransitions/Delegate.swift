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
		let diagnosticOperation = operation
		let diagnosticForceLegacy = ProcessInfo.processInfo.environment["NAVIGATION_AB_FORCE_LEGACY"] == "1"
			&& (diagnosticVariant == "baseline" || diagnosticVariant == "restore-displaced")
		let usesLegacyReattachment: Bool =
			if #unavailable(iOS 17, tvOS 17, visionOS 1) {
				true
			} else {
				diagnosticForceLegacy
			}
		animator.addCompletion { _ in
			@MainActor func record(_ event: String) {
				guard ["baseline", "no-reattach", "restore-displaced"].contains(diagnosticVariant ?? "") else { return }
				let entry = "\(ProcessInfo.processInfo.systemUptime) variant=\(diagnosticVariant ?? "unset") forcedLegacy=\(diagnosticForceLegacy) operation=\(diagnosticOperation) \(event) cancelled=\(transitionContext.transitionWasCancelled) from=\(diagnosticView(fromUIView)) to=\(diagnosticView(toUIView))"
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
			if usesLegacyReattachment {
				if diagnosticVariant == "no-reattach" {
					record("candidateSkippedReattachment")
					return
				}
				let survivor = transitionContext.transitionWasCancelled ? fromUIView : toUIView
				let displaced = diagnosticVariant == "restore-displaced" ? diagnosticFirstResponder(survivor) : nil
				let originalWindow = displaced?.window
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
				if diagnosticVariant == "restore-displaced" {
					if
						let displaced,
						let originalWindow,
						originalWindow.isKeyWindow,
						displaced.window === originalWindow,
						displaced === survivor || displaced.isDescendant(of: survivor),
						!displaced.isFirstResponder,
						displaced.canBecomeFirstResponder,
						diagnosticEligibleResponder(displaced),
						diagnosticCurrentResponder() == nil
					{
						let restored = displaced.becomeFirstResponder()
						record("restoreDisplaced result=\(restored)")
					} else {
						record("restoreSkipped")
					}
				}
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
	"view=\(ObjectIdentifier(view)) super=\(String(describing: view.superview.map(ObjectIdentifier.init))) window=\(view.window != nil) interactive=\(view.isUserInteractionEnabled) responder=\(String(describing: diagnosticFirstResponder(view)))"
}

@MainActor
private func diagnosticFirstResponder(_ view: UIView) -> UIView? {
	if view.isFirstResponder { return view }
	return view.subviews.lazy.compactMap { diagnosticFirstResponder($0) }.first
}

@MainActor
private func diagnosticEligibleResponder(_ responder: UIView) -> Bool {
	var current: UIView? = responder
	while let view = current {
		if view.isHidden || view.alpha == 0 || !view.isUserInteractionEnabled { return false }
		if let control = view as? UIControl, !control.isEnabled { return false }
		current = view.superview
	}
	return true
}

@MainActor
private final class DiagnosticResponderRequest: NSObject {
	weak var responder: UIResponder? = nil
}

extension UIResponder {
	@objc fileprivate func navigationTransitionsDiagnosticCaptureFirstResponder(_ request: DiagnosticResponderRequest) {
		if isFirstResponder { request.responder = self }
	}
}

@MainActor
private func diagnosticCurrentResponder() -> UIResponder? {
	let request = DiagnosticResponderRequest()
	UIApplication.shared.sendAction(
		#selector(UIResponder.navigationTransitionsDiagnosticCaptureFirstResponder(_:)),
		to: nil,
		from: request,
		for: nil,
	)
	return request.responder
}

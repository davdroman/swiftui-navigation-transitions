import UIKit

/// A transition context between two view controllers, which records how the transition completed.
@MainActor
final class TestTransitionContext: NSObject, UIViewControllerContextTransitioning {
	let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
	let from = UIViewController()
	let to = UIViewController()
	var transitionWasCancelled = false
	private(set) var completions: [Bool] = []

	var isAnimated: Bool { true }
	var isInteractive: Bool { false }
	var presentationStyle: UIModalPresentationStyle { .none }
	var targetTransform: CGAffineTransform { .identity }

	override init() {
		super.init()
		containerView.addSubview(from.view)
	}

	func updateInteractiveTransition(_ percentComplete: CGFloat) {}
	func finishInteractiveTransition() {}
	func cancelInteractiveTransition() {}
	func pauseInteractiveTransition() {}

	func completeTransition(_ didComplete: Bool) {
		completions.append(didComplete)
	}

	func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
		key == .from ? from : to
	}

	func view(forKey key: UITransitionContextViewKey) -> UIView? {
		key == .from ? from.view : to.view
	}

	func initialFrame(for vc: UIViewController) -> CGRect { containerView.bounds }
	func finalFrame(for vc: UIViewController) -> CGRect { containerView.bounds }
}

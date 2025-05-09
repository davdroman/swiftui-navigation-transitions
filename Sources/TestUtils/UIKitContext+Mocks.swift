public import UIKit
import IssueReporting

public class UnimplementedUIKitContext: NSObject, UIViewControllerContextTransitioning {
	public var containerView: UIView {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return .init()
	}

	public var isAnimated: Bool {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return false
	}

	public var isInteractive: Bool {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return false
	}

	public var transitionWasCancelled: Bool {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return false
	}

	public var presentationStyle: UIModalPresentationStyle {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return .none
	}

	public func updateInteractiveTransition(_ percentComplete: CGFloat) {
		reportIssue("\(Self.self).\(#function) is unimplemented")
	}

	public func finishInteractiveTransition() {
		reportIssue("\(Self.self).\(#function) is unimplemented")
	}

	public func cancelInteractiveTransition() {
		reportIssue("\(Self.self).\(#function) is unimplemented")
	}

	public func pauseInteractiveTransition() {
		reportIssue("\(Self.self).\(#function) is unimplemented")
	}

	public func completeTransition(_ didComplete: Bool) {
		reportIssue("\(Self.self).\(#function) is unimplemented")
	}

	public func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return nil
	}

	public func view(forKey key: UITransitionContextViewKey) -> UIView? {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return nil
	}

	public var targetTransform: CGAffineTransform {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return .init()
	}

	public func initialFrame(for vc: UIViewController) -> CGRect {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return .zero
	}

	public func finalFrame(for vc: UIViewController) -> CGRect {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return .zero
	}
}

public final class MockedUIKitContext: UnimplementedUIKitContext {
	public init(containerView: UIView) {
		self._containerView = containerView
	}

	private var _containerView: UIView
	override public var containerView: UIView {
		_containerView
	}
}

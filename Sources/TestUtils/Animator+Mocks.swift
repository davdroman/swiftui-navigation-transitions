public import Animator
public import UIKit
import IssueReporting

public final class UnimplementedAnimator: Animator {
	public init() {}

	@MainActor
	public func addAnimations(_ animation: @escaping () -> Void) {
		reportIssue("\(Self.self).\(#function) is unimplemented")
	}

	@MainActor
	public func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
		reportIssue("\(Self.self).\(#function) is unimplemented")
	}
}

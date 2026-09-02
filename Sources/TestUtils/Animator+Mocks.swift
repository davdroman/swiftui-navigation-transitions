public import Animator
import IssueReporting
public import UIKit

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

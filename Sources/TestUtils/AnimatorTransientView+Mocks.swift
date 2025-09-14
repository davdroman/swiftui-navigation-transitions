@testable public import Animator
import IssueReporting
import UIKit

extension AnimatorTransientView {
	public static var unimplemented: AnimatorTransientView {
		UnimplementedAnimatorTransientView()
	}
}

final class UnimplementedAnimatorTransientView: AnimatorTransientView {
	override var initial: AnimatorTransientView.Properties {
		get {
			reportIssue("\(Self.self).\(#function) is unimplemented")
			return .noop
		}
		set {
			reportIssue("\(Self.self).\(#function) is unimplemented")
		}
	}

	override var animation: AnimatorTransientView.Properties {
		get {
			reportIssue("\(Self.self).\(#function) is unimplemented")
			return .noop
		}
		set {
			reportIssue("\(Self.self).\(#function) is unimplemented")
		}
	}

	override var completion: AnimatorTransientView.Properties {
		get {
			reportIssue("\(Self.self).\(#function) is unimplemented")
			return .noop
		}
		set {
			reportIssue("\(Self.self).\(#function) is unimplemented")
		}
	}

	override subscript<T>(dynamicMember keyPath: KeyPath<UIView, T>) -> T {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return uiView[keyPath: keyPath]
	}

	init() {
		super.init(UIView())
	}

	override func setUIViewProperties(
		to properties: KeyPath<AnimatorTransientView, AnimatorTransientView.Properties>,
		force: Bool
	) {
		reportIssue("\(Self.self).\(#function) is unimplemented")
	}
}

extension AnimatorTransientView.Properties {
	fileprivate static let noop = Self(
		alpha: 0,
		transform: .init(.init()),
		zPosition: 0
	)
}

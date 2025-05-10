@testable public import Animator
internal import UIKit
import IssueReporting

extension AnimatorTransientView {
	public static var unimplemented: AnimatorTransientView {
		UnimplementedAnimatorTransientView()
	}
}

final class UnimplementedAnimatorTransientView: AnimatorTransientView {
	override public var initial: AnimatorTransientView.Properties {
		get {
			reportIssue("\(Self.self).\(#function) is unimplemented")
			return .noop
		}
		set {
			reportIssue("\(Self.self).\(#function) is unimplemented")
		}
	}

	override public var animation: AnimatorTransientView.Properties {
		get {
			reportIssue("\(Self.self).\(#function) is unimplemented")
			return .noop
		}
		set {
			reportIssue("\(Self.self).\(#function) is unimplemented")
		}
	}

	override public var completion: AnimatorTransientView.Properties {
		get {
			reportIssue("\(Self.self).\(#function) is unimplemented")
			return .noop
		}
		set {
			reportIssue("\(Self.self).\(#function) is unimplemented")
		}
	}

	override public subscript<T>(dynamicMember keyPath: KeyPath<UIView, T>) -> T {
		reportIssue("\(Self.self).\(#function) is unimplemented")
		return uiView[keyPath: keyPath]
	}

	public init() {
		super.init(UIView())
	}

	override public func setUIViewProperties(
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

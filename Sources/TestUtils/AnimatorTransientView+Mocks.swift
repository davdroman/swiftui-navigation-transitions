@_spi(package) @testable import Animator
import UIKit
import XCTestDynamicOverlay

extension AnimatorTransientView {
    public static var unimplemented: AnimatorTransientView {
        UnimplementedAnimatorTransientView()
    }
}

final class UnimplementedAnimatorTransientView: AnimatorTransientView {
    override public var initial: AnimatorTransientView.Properties {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return .noop
        }
        set {
            XCTFail("\(Self.self).\(#function) is unimplemented")
        }
    }

    override public var animation: AnimatorTransientView.Properties {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return .noop
        }
        set {
            XCTFail("\(Self.self).\(#function) is unimplemented")
        }
    }

    override public var completion: AnimatorTransientView.Properties {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return .noop
        }
        set {
            XCTFail("\(Self.self).\(#function) is unimplemented")
        }
    }

    override public subscript<T>(dynamicMember keyPath: KeyPath<UIView, T>) -> T {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return uiView[keyPath: keyPath]
    }

    public init() {
        super.init(UIView())
    }

    override public func setUIViewProperties(to properties: KeyPath<AnimatorTransientView, AnimatorTransientView.Properties>) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }
}

extension AnimatorTransientView.Properties {
    fileprivate static let noop = Self(
        alpha: 0,
        transform: .init(.init()),
        zPosition: 0
    )
}

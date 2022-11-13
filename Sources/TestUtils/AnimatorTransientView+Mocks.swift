@_spi(package) @testable import Animator
import UIKit
import XCTestDynamicOverlay

extension AnimatorTransientView {
    public static var unimplemented: AnimatorTransientView {
        UnimplementedAnimatorTransientView()
    }
}

final class UnimplementedAnimatorTransientView: AnimatorTransientView {
    public override var initial: AnimatorTransientView.Properties {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return .noop
        }
        set {
            XCTFail("\(Self.self).\(#function) is unimplemented")
        }
    }

    public override var animation: AnimatorTransientView.Properties {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return .noop
        }
        set {
            XCTFail("\(Self.self).\(#function) is unimplemented")
        }
    }

    public override var completion: AnimatorTransientView.Properties {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return .noop
        }
        set {
            XCTFail("\(Self.self).\(#function) is unimplemented")
        }
    }

    public override subscript<T>(dynamicMember keyPath: KeyPath<UIView, T>) -> T {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return uiView[keyPath: keyPath]
    }

    public init() {
        super.init(UIView())
    }

    public override func setUIViewProperties(to properties: KeyPath<AnimatorTransientView, AnimatorTransientView.Properties>) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }
}

fileprivate extension AnimatorTransientView.Properties {
    static let noop = Self(
        alpha: 0,
        transform: .init(.init()),
        zPosition: 0
    )
}

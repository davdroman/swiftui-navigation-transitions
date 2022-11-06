@_spi(package) @testable import Animator
import UIKit
import XCTestDynamicOverlay

public final class UnimplementedAnimatorTransientView: AnimatorTransientView {
    public override var initial: AnimatorTransientView.Properties {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return .init(alpha: 0, transform: .init())
        }
        set {
            XCTFail("\(Self.self).\(#function) is unimplemented")
        }
    }

    public override var animation: AnimatorTransientView.Properties {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return .init(alpha: 0, transform: .init())
        }
        set {
            XCTFail("\(Self.self).\(#function) is unimplemented")
        }
    }

    public override var completion: AnimatorTransientView.Properties {
        get {
            XCTFail("\(Self.self).\(#function) is unimplemented")
            return .init(alpha: 0, transform: .init())
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

#if DEBUG
import UIKit
import XCTestDynamicOverlay

@_spi(package)public final class UnimplementedAnimator: Animator {
    public init() {}

    public func addAnimations(_ animation: @escaping () -> Void) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    public func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }
}
#endif

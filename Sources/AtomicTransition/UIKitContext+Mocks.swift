#if DEBUG
import UIKit
import XCTestDynamicOverlay

@_spi(package)public class UnimplementedUIKitContext: NSObject, UIViewControllerContextTransitioning {
    public var containerView: UIView {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .init()
    }

    public var isAnimated: Bool {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return false
    }

    public var isInteractive: Bool {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return false
    }

    public var transitionWasCancelled: Bool {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return false
    }

    public var presentationStyle: UIModalPresentationStyle {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .none
    }

    public func updateInteractiveTransition(_ percentComplete: CGFloat) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    public func finishInteractiveTransition() {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    public func cancelInteractiveTransition() {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    public func pauseInteractiveTransition() {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    public func completeTransition(_ didComplete: Bool) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    public func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return nil
    }

    public func view(forKey key: UITransitionContextViewKey) -> UIView? {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return nil
    }

    public var targetTransform: CGAffineTransform {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .init()
    }

    public func initialFrame(for vc: UIViewController) -> CGRect {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .zero
    }

    public func finalFrame(for vc: UIViewController) -> CGRect {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .zero
    }
}

@_spi(package)public final class MockedUIKitContext: UnimplementedUIKitContext {
    public init(containerView: UIView) {
        self._containerView = containerView
    }

    private var _containerView: UIView
    public override var containerView: UIView {
        _containerView
    }
}
#endif

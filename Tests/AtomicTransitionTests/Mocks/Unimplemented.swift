@_spi(package) import Animator
import AtomicTransition
import XCTest

extension AtomicTransition.TransientView {
    static var unimplemented: Self {
        .init(UIView())
    }
}

final class UnimplementedContext: NSObject, AtomicTransition.Context {
    var containerView: UIView {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .init()
    }

    var isAnimated: Bool {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return false
    }

    var isInteractive: Bool {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return false
    }

    var transitionWasCancelled: Bool {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return false
    }

    var presentationStyle: UIModalPresentationStyle {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .none
    }

    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    func finishInteractiveTransition() {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    func cancelInteractiveTransition() {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    func pauseInteractiveTransition() {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    func completeTransition(_ didComplete: Bool) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return nil
    }

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return nil
    }

    var targetTransform: CGAffineTransform {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .init()
    }

    func initialFrame(for vc: UIViewController) -> CGRect {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .zero
    }

    func finalFrame(for vc: UIViewController) -> CGRect {
        XCTFail("\(Self.self).\(#function) is unimplemented")
        return .zero
    }
}

extension AtomicTransition.Context where Self == UnimplementedContext {
    static var unimplemented: Self { .init() }
}

final class UnimplementedAnimator: AtomicTransition.Animator {
    func addAnimations(_ animation: @escaping () -> Void) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }

    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        XCTFail("\(Self.self).\(#function) is unimplemented")
    }
}

extension AtomicTransition.Animator where Self == UnimplementedAnimator {
    static var unimplemented: Self { .init() }
}

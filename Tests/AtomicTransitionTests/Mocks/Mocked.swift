import AtomicTransition
import XCTest

final class MockedContext: UnimplementedContext {
    init(containerView: UIView) {
        self._containerView = containerView
    }

    private var _containerView: UIView
    override var containerView: UIView {
        _containerView
    }
}

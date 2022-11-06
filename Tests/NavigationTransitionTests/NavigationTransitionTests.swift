@_spi(package) @testable import NavigationTransition
import TestUtils

final class NavigationTransitionTests: XCTestCase {
    func testPrepare() {
        let animatorUsed = UnimplementedAnimator()

        let sut = NavigationTransition(withAnimator: { animator, operation, context in
            
        })

//        sut.prepare(animatorUsed, for: <#T##NavigationTransition.Operation#>, in: <#T##NavigationTransition._Context#>)
    }

    func testInitWithTransientViews() {

    }

    func testAnimation() {

    }
}

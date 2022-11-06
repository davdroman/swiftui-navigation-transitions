@_spi(package) @testable import NavigationTransition
@_spi(package) import TestUtils

final class NavigationTransitionTests: XCTestCase {
    func testPrepare() {
        let animatorUsed = UnimplementedAnimator()
        let operationUsed = NavigationTransition.Operation.random()
        let contextUsed = UnimplementedContext()

        var handleCalls = 0
        let sut = NavigationTransition.spy { animator, operation, context in
            XCTAssertIdentical(animator, animatorUsed)
            XCTAssertEqual(operation, operationUsed)
            XCTAssertIdentical(context, contextUsed)
            handleCalls += 1
        }

        XCTAssertEqual(handleCalls, 0)
        sut.prepare(animatorUsed, for: operationUsed, in: contextUsed)
        XCTAssertEqual(handleCalls, 1)
    }

    func testInitWithTransientViews() {

    }

    func testAnimation() {

    }
}

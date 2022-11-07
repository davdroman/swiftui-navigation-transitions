@_spi(package) import AtomicTransition
import TestUtils

final class IdentityTests: XCTestCase {
    let viewUsed = UnimplementedAnimatorTransientView()
    let contextUsed = UnimplementedUIKitContext()

    func testInsertion() {
        AtomicTransition.identity.prepare(viewUsed, for: .insertion, in: contextUsed)
    }

    func testRemoval() {
        AtomicTransition.identity.prepare(viewUsed, for: .removal, in: contextUsed)
    }
}

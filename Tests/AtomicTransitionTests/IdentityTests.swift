@_spi(package) import AtomicTransition
import TestUtils
import XCTest

final class IdentityTests: XCTestCase {
    let animatorUsed = UnimplementedAnimator()
    let viewUsed = UnimplementedAnimatorTransientView()
    let contextUsed = UnimplementedUIKitContext()

    func testInsertion() {
        AtomicTransition.identity.prepare(animatorUsed, or: viewUsed, for: .insertion, in: contextUsed)
    }

    func testRemoval() {
        AtomicTransition.identity.prepare(animatorUsed, or: viewUsed, for: .removal, in: contextUsed)
    }
}

@_spi(package) import AtomicTransition
import TestUtils

final class IdentityTests: XCTestCase {
	func testInsertion() {
		Identity().transition(.unimplemented, for: .insertion, in: .unimplemented)
	}

	func testRemoval() {
		Identity().transition(.unimplemented, for: .removal, in: .unimplemented)
	}
}

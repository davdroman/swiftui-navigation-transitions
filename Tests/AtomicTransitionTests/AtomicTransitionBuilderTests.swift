import AtomicTransition
import enum SwiftUI.Edge
import Testing
import TestUtils

@MainActor
struct AtomicTransitionBuilderTests {
	@Test(arguments: [true, false])
	func `if runs its transition only when its condition holds`(condition: Bool) {
		var ran = false
		let sut = Group {
			if condition {
				Spy { ran = true }
			}
		}

		sut.transition(.unimplemented, for: .insertion, in: .unimplemented)

		#expect(ran == condition)
	}

	@Test(arguments: [true, false])
	func `if-else runs the branch its condition picks`(condition: Bool) {
		var branches: [Bool] = []
		let sut = Group {
			if condition {
				Spy { branches.append(true) }
			} else {
				Spy { branches.append(false) }
			}
		}

		sut.transition(.unimplemented, for: .insertion, in: .unimplemented)

		#expect(branches == [condition])
	}

	@Test(arguments: [true, false])
	func `mirroring a conditional mirrors the branch its condition picks`(condition: Bool) {
		var calls: [(branch: Bool, isMirrored: Bool)] = []
		let sut = Group {
			if condition {
				MirrorableSpy { isMirrored, _, _ in calls.append((true, isMirrored)) }
			} else {
				MirrorableSpy { isMirrored, _, _ in calls.append((false, isMirrored)) }
			}
		}

		sut.mirrored().transition(.unimplemented, for: .insertion, in: .unimplemented)

		#expect(calls.map(\.branch) == [condition])
		#expect(calls.map(\.isMirrored) == [true])
	}

	@Test
	func `conditionals compare by the transition they hold`() {
		func optional(_ condition: Bool) -> Group<some AtomicTransition & Equatable> {
			Group { if condition { Move(edge: .top) } }
		}
		func conditional(_ condition: Bool) -> Group<some AtomicTransition & Equatable> {
			Group {
				if condition {
					Move(edge: .top)
				} else {
					Offset(x: 3)
				}
			}
		}

		#expect(optional(true) == optional(true))
		#expect(optional(true) != optional(false))
		#expect(conditional(true) == conditional(true))
		#expect(conditional(true) != conditional(false))
	}
}

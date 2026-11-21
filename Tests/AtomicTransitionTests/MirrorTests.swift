import AtomicTransition
import struct SwiftUI.Angle
import enum SwiftUI.Edge
import Testing
import TestUtils

@MainActor
struct MirrorTests {
	@Test
	func `mirroring twice round-trips`() {
		expectRoundTrip(Move(edge: .top))
		expectRoundTrip(Move(edge: .leading))
		expectRoundTrip(Move(edge: .bottom))
		expectRoundTrip(Move(edge: .trailing))
		expectRoundTrip(Offset(x: 3, y: 4))
		expectRoundTrip(Rotate(.degrees(30)))
		expectRoundTrip(Rotate3D(.degrees(30), axis: (x: 1, y: 0, z: 0), perspective: 2))
		expectRoundTrip(Scale(0.5))
		expectRoundTrip(Opacity())
		expectRoundTrip(ZPosition(2))
		expectRoundTrip(Identity())
		expectRoundTrip(Combined { Move(edge: .top); Offset(x: 3) })
		expectRoundTrip(Group { Move(edge: .top); Rotate(.degrees(30)) })
		expectRoundTrip(OnInsertion { Move(edge: .leading) })
		expectRoundTrip(OnRemoval { Offset(y: 4) })
		expectRoundTrip(MirrorInsertion { Move(edge: .leading) })
		expectRoundTrip(MirrorRemoval { Move(edge: .leading) })
		for condition in [true, false] {
			expectRoundTrip(Group { if condition { Move(edge: .top) } })
			expectRoundTrip(Group {
				if condition {
					Move(edge: .top)
				} else {
					Offset(x: 3)
				}
			})
		}
	}

	@Test
	func `move mirrors to the opposite edge`() {
		#expect(Move(edge: .top).mirrored() == Move(edge: .bottom))
		#expect(Move(edge: .bottom).mirrored() == Move(edge: .top))
		#expect(Move(edge: .leading).mirrored() == Move(edge: .trailing))
		#expect(Move(edge: .trailing).mirrored() == Move(edge: .leading))
	}

	@Test
	func `offset and rotate mirror to the opposite direction`() {
		#expect(Offset(x: 3, y: -4).mirrored() == Offset(x: -3, y: 4))
		#expect(Rotate(.degrees(30)).mirrored() == Rotate(.degrees(-30)))
	}

	@Test
	func `rotate 3D mirrors its perspective`() {
		let sut = Rotate3D(.degrees(30), axis: (x: 1, y: 0, z: 0), perspective: 2)

		#expect(sut.mirrored() == Rotate3D(.degrees(30), axis: (x: 1, y: 0, z: 0), perspective: -2))
		#expect(sut.mirrored() != sut)
	}

	@Test
	func `symmetric transitions mirror to themselves`() {
		#expect(Scale(0.5).mirrored() == Scale(0.5))
		#expect(Opacity().mirrored() == Opacity())
		#expect(ZPosition(2).mirrored() == ZPosition(2))
		#expect(Identity().mirrored() == Identity())
	}

	@Test
	func `composite transitions mirror their parts`() {
		#expect(Combined { Move(edge: .top); Offset(x: 3) }.mirrored() == Combined { Move(edge: .bottom); Offset(x: -3) })
		#expect(OnInsertion { Move(edge: .top) }.mirrored() == OnInsertion { Move(edge: .bottom) })
		#expect(OnRemoval { Move(edge: .top) }.mirrored() == OnRemoval { Move(edge: .bottom) })
	}

	@Test
	func `mirror insertion and mirror removal swap without mirroring their transition`() {
		#expect(MirrorInsertion { Move(edge: .top) }.mirrored() == MirrorRemoval { Move(edge: .top) })
		#expect(MirrorRemoval { Move(edge: .top) }.mirrored() == MirrorInsertion { Move(edge: .top) })
	}

	@Test
	func `mirror insertion runs only on insertion`() {
		var operations: [AtomicTransitionOperation] = []
		let sut = MirrorInsertion { Spy { _, operation, _ in operations.append(operation) } }

		sut.transition(.unimplemented, for: .insertion, in: .unimplemented)
		sut.transition(.unimplemented, for: .removal, in: .unimplemented)

		#expect(operations == [.insertion])
	}

	@Test
	func `mirror removal runs only on removal`() {
		var operations: [AtomicTransitionOperation] = []
		let sut = MirrorRemoval { Spy { _, operation, _ in operations.append(operation) } }

		sut.transition(.unimplemented, for: .insertion, in: .unimplemented)
		sut.transition(.unimplemented, for: .removal, in: .unimplemented)

		#expect(operations == [.removal])
	}

	private func expectRoundTrip<T: MirrorableAtomicTransition & Equatable>(
		_ transition: T,
		sourceLocation: SourceLocation = #_sourceLocation,
	) where T.Mirrored: MirrorableAtomicTransition, T.Mirrored.Mirrored == T {
		#expect(transition.mirrored().mirrored() == transition, sourceLocation: sourceLocation)
	}
}

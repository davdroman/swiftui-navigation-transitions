@testable import Animator
import AtomicTransition
import SwiftUI
import Testing
import TestUtils

@MainActor
struct Rotate3DTests {
	let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
	let container = UIView()
	let properties = AnimatorTransientViewProperties(alpha: 1, transform: .identity, zPosition: 0)

	@Test
	func insertion() {
		let view = AnimatorTransientView(uiView)

		Rotate3D(.radians(.pi / 2), axis: (x: 0, y: 1, z: 0), perspective: 2).transition(
			view,
			for: .insertion,
			in: container,
		)

		var initial = properties
		initial.transform.m34 = 2.0 / 200
		initial.transform.rotate(by: .pi / 2, y: 1)
		expectNoDifference(view.initial, initial)
		var animation = properties
		animation.transform = .identity
		expectNoDifference(view.animation, animation)
		expectNoDifference(view.completion, properties)
		#expect(!uiView.layer.isDoubleSided)
	}

	@Test
	func removal() {
		let view = AnimatorTransientView(uiView)

		Rotate3D(.radians(.pi / 2), axis: (x: 0, y: 1, z: 0), perspective: 2).transition(view, for: .removal, in: container)

		var animation = properties
		animation.transform.m34 = -2.0 / 200
		animation.transform.rotate(by: .pi / 2, y: 1)
		expectNoDifference(view.initial, properties)
		expectNoDifference(view.animation, animation)
		var completion = properties
		completion.transform = .identity
		expectNoDifference(view.completion, completion)
		#expect(!uiView.layer.isDoubleSided)
	}

	@Test
	func `views without a size rotate without perspective`() {
		let view = AnimatorTransientView(UIView())

		Rotate3D(.radians(.pi / 2), axis: (x: 0, y: 1, z: 0)).transition(view, for: .insertion, in: container)

		var initial = properties
		initial.transform.rotate(by: .pi / 2, y: 1)
		expectNoDifference(view.initial, initial)
	}

	@Test
	func `equality includes every parameter`() {
		let sut = Rotate3D(.radians(.pi / 2), axis: (x: 0, y: 1, z: 0), perspective: 2)

		#expect(sut == Rotate3D(.radians(.pi / 2), axis: (x: 0, y: 1, z: 0), perspective: 2))
		#expect(sut.hashValue == Rotate3D(.radians(.pi / 2), axis: (x: 0, y: 1, z: 0), perspective: 2).hashValue)
		#expect(sut != Rotate3D(.radians(.pi / 4), axis: (x: 0, y: 1, z: 0), perspective: 2))
		#expect(sut != Rotate3D(.radians(.pi / 2), axis: (x: 1, y: 0, z: 0), perspective: 2))
		#expect(sut != Rotate3D(.radians(.pi / 2), axis: (x: 0, y: 1, z: 0), perspective: 1))
	}
}

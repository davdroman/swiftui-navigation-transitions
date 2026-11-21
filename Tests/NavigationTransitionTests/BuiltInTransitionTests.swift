@testable import Animator
import NavigationTransition
import SwiftUI
import Testing
import TestUtils

/// The changes each built-in transition makes to the views, with a container of 100 × 200 points.
@MainActor
struct BuiltInTransitionTests {
	let views = TransitionViews()

	@Test
	func `horizontal slide pushes right to left`() {
		views.run(Slide(axis: .horizontal), for: .push)

		expectNoDifference(Stages(of: views.to), .movingIn(fromX: 100, y: 0))
		expectNoDifference(Stages(of: views.from), .movingOut(toX: -100, y: 0))
	}

	@Test
	func `horizontal slide pops left to right`() {
		views.run(Slide(axis: .horizontal), for: .pop)

		expectNoDifference(Stages(of: views.to), .movingIn(fromX: -100, y: 0))
		expectNoDifference(Stages(of: views.from), .movingOut(toX: 100, y: 0))
	}

	@Test
	func `vertical slide pushes bottom to top`() {
		views.run(Slide(axis: .vertical), for: .push)

		expectNoDifference(Stages(of: views.to), .movingIn(fromX: 0, y: 200))
		expectNoDifference(Stages(of: views.from), .movingOut(toX: 0, y: -200))
	}

	@Test
	func `vertical slide pops top to bottom`() {
		views.run(Slide(axis: .vertical), for: .pop)

		expectNoDifference(Stages(of: views.to), .movingIn(fromX: 0, y: -200))
		expectNoDifference(Stages(of: views.from), .movingOut(toX: 0, y: 200))
	}

	@Test
	func `slide defaults to the horizontal axis`() {
		#expect(Slide() == Slide(axis: .horizontal))
	}

	@Test
	func `fade in fades the to view in above the from view`() {
		for operation in [NavigationTransitionOperation.push, .pop] {
			let views = TransitionViews()

			views.run(Fade(.in), for: operation)

			expectNoDifference(Stages(of: views.to), .fadingIn(raised: true))
			expectNoDifference(Stages(of: views.from), .unchanged)
		}
	}

	@Test
	func `fade out fades the from view out above the to view`() {
		for operation in [NavigationTransitionOperation.push, .pop] {
			let views = TransitionViews()

			views.run(Fade(.out), for: operation)

			expectNoDifference(Stages(of: views.to), .unchanged)
			expectNoDifference(Stages(of: views.from), .fadingOut(raised: true))
		}
	}

	@Test
	func `cross fade fades both views`() {
		for operation in [NavigationTransitionOperation.push, .pop] {
			let views = TransitionViews()

			views.run(Fade(.cross), for: operation)

			expectNoDifference(Stages(of: views.to), .fadingIn(raised: false))
			expectNoDifference(Stages(of: views.from), .fadingOut(raised: false))
		}
	}
}

/// The properties a transition sets on a view at each stage.
private struct Stages: Equatable {
	typealias Properties = AnimatorTransientViewProperties

	var initial = Properties.unchanged
	var animation = Properties.unchanged
	var completion = Properties.unchanged

	static let unchanged = Self()

	init() {}

	@MainActor
	init(of view: AnimatorTransientView) {
		initial = view.initial
		animation = view.animation
		completion = view.completion
	}

	static func movingIn(fromX x: CGFloat, y: CGFloat) -> Self {
		var stages = Self()
		stages.initial.transform.translate(x: x, y: y)
		stages.animation.transform = .identity
		return stages
	}

	static func movingOut(toX x: CGFloat, y: CGFloat) -> Self {
		var stages = Self()
		stages.animation.transform.translate(x: x, y: y)
		stages.completion.transform = .identity
		return stages
	}

	static func fadingIn(raised: Bool) -> Self {
		var stages = Self()
		stages.initial.alpha = 0
		stages.animation.alpha = 1
		if raised {
			stages.animation.zPosition = 1
			stages.completion.zPosition = 0
		}
		return stages
	}

	static func fadingOut(raised: Bool) -> Self {
		var stages = Self()
		stages.animation.alpha = 0
		stages.completion.alpha = 1
		if raised {
			stages.animation.zPosition = 1
			stages.completion.zPosition = 0
		}
		return stages
	}
}

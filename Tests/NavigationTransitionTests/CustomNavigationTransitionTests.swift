import Animator
@testable import NavigationTransition
import Testing
import TestUtils
import UIKit

@MainActor
struct CustomNavigationTransitionTests {
	let views = TransitionViews()

	@Test
	func `only the default transition is the system transition`() {
		#expect(CustomNavigationTransition.default.isDefault)
		#expect(!CustomNavigationTransition.slide.isDefault)
		#expect(!CustomNavigationTransition.fade(.cross).isDefault)
		#expect(!CustomNavigationTransition(NoopPrimitiveTransition()).isDefault)
	}

	@Test
	func `transitions animate with the default animation unless given one`() {
		#expect(CustomNavigationTransition.slide.animation != nil)
		#expect(CustomNavigationTransition.slide.animation(nil).animation == nil)
		#expect(CustomNavigationTransition.slide.animation(nil).animation(.linear).animation != nil)
	}

	@Test
	func `a transition runs the transition it wraps`() {
		var operations: [NavigationTransitionOperation] = []
		let sut = CustomNavigationTransition(OnPush { Spy { operations.append(.push) } })

		run(sut, for: .push)
		run(sut, for: .pop)

		#expect(operations == [.push, .push])
	}

	@Test
	func `combining two transitions runs both in order`() {
		var order: [Int] = []
		let first = CustomNavigationTransition(OnPush { Spy { order.append(1) } })
		let second = CustomNavigationTransition(OnPush { Spy { order.append(2) } })

		run(first.combined(with: second), for: .push)

		#expect(order == [1, 1, 2, 2])
	}

	@Test
	func `combining with a primitive transition reports an issue and keeps the left-hand side`() {
		var ran = false
		let transient = CustomNavigationTransition(OnPush { Spy { ran = true } })

		var combinedWithPrimitive = transient
		var primitiveCombined = CustomNavigationTransition.slide
		var primitivesCombined = CustomNavigationTransition.slide

		withKnownIssue {
			combinedWithPrimitive = transient.combined(with: .default)
		}
		withKnownIssue {
			primitiveCombined = CustomNavigationTransition.default.combined(with: transient)
		}
		withKnownIssue {
			primitivesCombined = CustomNavigationTransition.default.combined(with: .default)
		}

		run(combinedWithPrimitive, for: .push)
		#expect(ran)
		#expect(primitiveCombined.isDefault)
		#expect(primitivesCombined.isDefault)
	}

	@Test
	func `operations map from UIKit's navigation operations`() {
		#expect(NavigationTransitionOperation(.push) == .push)
		#expect(NavigationTransitionOperation(.pop) == .pop)
		#expect(NavigationTransitionOperation(.none) == nil)
	}

	@Test
	func `default interactivity matches the platform`() {
		#if os(iOS)
		if #available(iOS 26, macCatalyst 26, *) {
			#expect(CustomNavigationTransition.Interactivity.default == .contentPan)
		} else {
			#expect(CustomNavigationTransition.Interactivity.default == .edgePan)
		}
		#else
		#expect(CustomNavigationTransition.Interactivity.default == .edgePan)
		#endif
	}

	private func run(_ transition: CustomNavigationTransition, for operation: NavigationTransitionOperation) {
		guard case let .transient(handler) = transition.handler else {
			Issue.record("Expected a transition built from views")
			return
		}
		handler(views.from, views.to, operation, views.container)
	}
}

private struct NoopPrimitiveTransition: PrimitiveNavigationTransition {
	func transition(with animator: any Animator, for operation: TransitionOperation, in context: any Context) {}
}

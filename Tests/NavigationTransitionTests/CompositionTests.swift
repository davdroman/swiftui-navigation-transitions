import Animator
import NavigationTransition
import Testing
import TestUtils

@MainActor
struct CompositionTests {
	let views = TransitionViews()

	@Test
	func `on push runs on push only, removing the from view and inserting the to view`() {
		var calls: [String] = []
		let sut = OnPush { Spy { view, operation, _ in calls.append(describe(view, operation)) } }

		views.run(sut, for: .push)
		views.run(sut, for: .pop)

		#expect(calls == ["from removal", "to insertion"])
	}

	@Test
	func `on pop runs on pop only, removing the from view and inserting the to view`() {
		var calls: [String] = []
		let sut = OnPop { Spy { view, operation, _ in calls.append(describe(view, operation)) } }

		views.run(sut, for: .push)
		views.run(sut, for: .pop)

		#expect(calls == ["from removal", "to insertion"])
	}

	@Test
	func `mirror push runs its transition on push and the mirrored transition on pop`() {
		var calls: [String] = []
		let sut = MirrorPush {
			MirrorableSpy { isMirrored, view, operation in calls.append(describe(view, operation, isMirrored)) }
		}

		views.run(sut, for: .push)
		views.run(sut, for: .pop)

		#expect(calls == [
			"from removal",
			"to insertion",
			"from removal mirrored",
			"to insertion mirrored",
		])
	}

	@Test
	func `mirror pop runs the mirrored transition on push and its transition on pop`() {
		var calls: [String] = []
		let sut = MirrorPop {
			MirrorableSpy { isMirrored, view, operation in calls.append(describe(view, operation, isMirrored)) }
		}

		views.run(sut, for: .push)
		views.run(sut, for: .pop)

		#expect(calls == [
			"from removal mirrored",
			"to insertion mirrored",
			"from removal",
			"to insertion",
		])
	}

	@Test
	func `pick push runs only the push part of a transition`() {
		var operations: [NavigationTransitionOperation] = []
		let sut = PickPush {
			OnPush { Spy { operations.append(.push) } }
			OnPop { Spy { operations.append(.pop) } }
		}

		views.run(sut, for: .push)
		views.run(sut, for: .pop)

		#expect(operations == [.push, .push])
	}

	@Test
	func `pick pop runs only the pop part of a transition`() {
		var operations: [NavigationTransitionOperation] = []
		let sut = PickPop {
			OnPush { Spy { operations.append(.push) } }
			OnPop { Spy { operations.append(.pop) } }
		}

		views.run(sut, for: .push)
		views.run(sut, for: .pop)

		#expect(operations == [.pop, .pop])
	}

	@Test
	func `combined runs its transitions in order`() {
		var order: [Int] = []
		let sut = Combined {
			OnPush { Spy { order.append(1) } }
			OnPush { Spy { order.append(2) } }
			OnPush { Spy { order.append(3) } }
		}

		views.run(sut, for: .push)

		#expect(order == [1, 1, 2, 2, 3, 3])
	}

	@Test(arguments: [true, false])
	func `if runs its transition only when its condition holds`(condition: Bool) {
		var ran = false
		let sut = PickPush {
			if condition {
				OnPush { Spy { ran = true } }
			}
		}

		views.run(sut, for: .push)

		#expect(ran == condition)
	}

	@Test(arguments: [true, false])
	func `if-else runs the branch its condition picks`(condition: Bool) {
		var branches: Set<Bool> = []
		let sut = PickPush {
			if condition {
				OnPush { Spy { branches.insert(true) } }
			} else {
				OnPush { Spy { branches.insert(false) } }
			}
		}

		views.run(sut, for: .push)

		#expect(branches == [condition])
	}

	private func describe(
		_ view: AnimatorTransientView,
		_ operation: AtomicTransitionOperation,
		_ isMirrored: Bool = false,
	) -> String {
		"\(views.name(of: view)) \(operation)" + (isMirrored ? " mirrored" : "")
	}
}

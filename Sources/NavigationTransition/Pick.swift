/// Used to isolate the push portion of a full `NavigationTransitionProtocol` and execute it on push, ignoring the pop portion.
public struct PickPush<Transition: NavigationTransitionProtocol>: NavigationTransitionProtocol {
	private let transition: Transition

	public init(@NavigationTransitionBuilder transition: () -> Transition) {
		self.transition = transition()
	}

	public func transition(
		from fromView: TransientView,
		to toView: TransientView,
		for operation: TransitionOperation,
		in container: Container
	) {
		switch operation {
		case .push:
			transition.transition(from: fromView, to: toView, for: operation, in: container)
		case .pop:
			return
		}
	}
}

extension PickPush: Equatable where Transition: Equatable {}
extension PickPush: Hashable where Transition: Hashable {}

/// Used to isolate the pop portion of a full `NavigationTransitionProtocol` and execute it on pop, ignoring the push portion.
public struct PickPop<Transition: NavigationTransitionProtocol>: NavigationTransitionProtocol {
	private let transition: Transition

	public init(@NavigationTransitionBuilder transition: () -> Transition) {
		self.transition = transition()
	}

	public func transition(
		from fromView: TransientView,
		to toView: TransientView,
		for operation: TransitionOperation,
		in container: Container
	) {
		switch operation {
		case .push:
			return
		case .pop:
			transition.transition(from: fromView, to: toView, for: operation, in: container)
		}
	}
}

extension PickPop: Equatable where Transition: Equatable {}
extension PickPop: Hashable where Transition: Hashable {}

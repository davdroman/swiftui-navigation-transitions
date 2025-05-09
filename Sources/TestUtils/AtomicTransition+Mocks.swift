@testable public import AtomicTransition

public struct Spy: AtomicTransition {
	public typealias Handler = (TransientView, TransitionOperation, Container) -> Void

	private let handler: Handler

	public init(handler: @escaping Handler) {
		self.handler = handler
	}

	public init(handler: @escaping () -> Void) {
		self.handler = { _, _, _ in handler() }
	}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		handler(view, operation, container)
	}
}

public struct Noop<Tag>: AtomicTransition {
	public init() {}

	public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
		// NO-OP
	}
}

extension Noop: Hashable {}

extension AtomicTransitionOperation {
	public static func random() -> Self {
		[.insertion, .removal].randomElement()!
	}
}

@testable import AtomicTransition

extension AtomicTransition.Operation {
    public static func random() -> Self {
        [.insertion, .removal].randomElement()!
    }
}

extension AtomicTransitionOperation {
    public static func random() -> Self {
        [.insertion, .removal].randomElement()!
    }
}

extension AtomicTransition {
    public static func spy(_ handler: @escaping () -> Void) -> Self {
        .init { _, _, _ in
            handler()
        }
    }

    public static func spy(_ handler: @escaping _Handler) -> Self {
        .init(handler: handler)
    }
}

public struct Spy: AtomicTransitionProtocol {
    public typealias Handler = (TransientView, TransitionOperation, Container) -> Void

    private let handler: Handler

    public init(handler: @escaping Handler) {
        self.handler = handler
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        handler(view, operation, container)
    }
}

public struct Noop<Tag>: AtomicTransitionProtocol {
    public init() {}

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        // NO-OP
    }
}

extension Noop: Hashable {}

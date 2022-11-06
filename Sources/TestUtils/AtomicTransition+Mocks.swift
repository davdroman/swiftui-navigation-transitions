@testable import AtomicTransition

extension AtomicTransition {
    public static func spy(_ handler: @escaping () -> Void) -> Self {
        .init { _, _, _, _ in
            handler()
        }
    }

    public static func spy(_ handler: @escaping _Handler) -> Self {
        .init(handler: handler)
    }
}

extension AtomicTransition.Operation {
    public static func random() -> Self {
        [.insertion, .removal].randomElement()!
    }
}

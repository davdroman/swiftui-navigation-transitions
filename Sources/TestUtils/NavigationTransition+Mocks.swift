@testable import NavigationTransition

extension NavigationTransition {
    public static func spy(_ handler: @escaping () -> Void) -> Self {
        .init { _, _, _ in
            handler()
        }
    }

    public static func spy(_ handler: @escaping _Handler) -> Self {
        .init(handler: handler)
    }
}

extension NavigationTransition {
    public static var noop: Self {
        .init { _, _, _ in }
    }
}

extension NavigationTransition.Operation {
    public static func random() -> Self {
        [.push, .pop].randomElement()!
    }
}

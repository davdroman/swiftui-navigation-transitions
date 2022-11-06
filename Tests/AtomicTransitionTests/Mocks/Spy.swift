@_spi(package) @testable import AtomicTransition

extension AtomicTransition {
    static func spy(_ handler: @escaping () -> Void) -> Self {
        .init { _, _, _, _ in
            handler()
        }
    }

    static func spy(_ handler: @escaping _Handler) -> Self {
        .init(handler: handler)
    }
}

#if DEBUG
@_spi(package)public extension AtomicTransition {
    static func spy(_ handler: @escaping () -> Void) -> Self {
        .init { _, _, _, _ in
            handler()
        }
    }

    static func spy(_ handler: @escaping _Handler) -> Self {
        .init(handler: handler)
    }
}

@_spi(package)public extension AtomicTransition.Operation {
    static func random() -> Self {
        [.insertion, .removal].randomElement()!
    }
}

#endif

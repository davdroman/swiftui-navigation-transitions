@testable import AtomicTransition

extension AtomicTransition {
    static func spy(_ handler: @escaping () -> Void) -> Self {
        .init { _, _, _, _ in
            handler()
        }
    }
}

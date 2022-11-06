import AtomicTransition

extension AtomicTransition.Operation {
    static func random() -> Self {
        [.insertion, .removal].randomElement()!
    }
}

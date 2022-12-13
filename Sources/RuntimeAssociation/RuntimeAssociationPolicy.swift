import ObjectiveC

public enum RuntimeAssociationPolicy {
    public enum Atomicity {
        case atomic
        case nonatomic
    }

    case assign
    case copy(Atomicity)
    case retain(Atomicity)
}

extension objc_AssociationPolicy {
    init(_ policy: RuntimeAssociationPolicy) {
        switch policy {
        case .assign:
            self = .OBJC_ASSOCIATION_ASSIGN
        case .copy(.atomic):
            self = .OBJC_ASSOCIATION_COPY
        case .copy(.nonatomic):
            self = .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .retain(.atomic):
            self = .OBJC_ASSOCIATION_RETAIN
        case .retain(.nonatomic):
            self = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        }
    }
}

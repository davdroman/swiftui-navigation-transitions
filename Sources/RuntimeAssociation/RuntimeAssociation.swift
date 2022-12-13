import ObjectiveC

public protocol RuntimeAssociation: AnyObject {
    subscript<T>(forKey key: String, policy: RuntimeAssociationPolicy) -> T? { get set }
}

extension RuntimeAssociation {
    public subscript<T>(forKey key: String = #function, policy: RuntimeAssociationPolicy = .retain(.nonatomic)) -> T? {
        get {
            let key = unsafeBitCast(Selector(key), to: UnsafeRawPointer.self)
            return objc_getAssociatedObject(self, key) as? T
        }
        set {
            let key = unsafeBitCast(Selector(key), to: UnsafeRawPointer.self)
            objc_setAssociatedObject(self, key, newValue, .init(policy))
        }
    }
}

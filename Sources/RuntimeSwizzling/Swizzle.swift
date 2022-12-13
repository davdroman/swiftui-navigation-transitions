import ObjectiveC

public var swizzleLogs = false

public func swizzle(_ type: AnyObject.Type, _ original: Selector, _ swizzled: Selector) {
    guard let originalMethod = class_getInstanceMethod(type, original) else {
        assertionFailure("[Swizzling] Instance method \(type).\(original) not found.")
        return
    }
    guard let swizzledMethod = class_getInstanceMethod(type, swizzled) else {
        assertionFailure("[Swizzling] Instance method \(type).\(swizzled) not found.")
        return
    }
    if swizzleLogs {
        print("[Swizzling] [\(type) \(original) <~> \(swizzled)]")
    }
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

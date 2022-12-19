import ObjectiveC

public var swizzleLogs = false

public func swizzle(_ type: AnyObject.Type, _ original: Selector, _ swizzled: Selector) {
    guard !swizzlingHistory.contains(type, original, swizzled) else {
        return
    }

    swizzlingHistory.add(type, original, swizzled)

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

private struct SwizzlingHistory {
    private var map: [Int: Void] = [:]

    func contains(_ type: AnyObject.Type, _ original: Selector, _ swizzled: Selector) -> Bool {
        map[hash(type, original, swizzled)] != nil
    }

    mutating func add(_ type: AnyObject.Type, _ original: Selector, _ swizzled: Selector) {
        map[hash(type, original, swizzled)] = ()
    }

    private func hash(_ type: AnyObject.Type, _ original: Selector, _ swizzled: Selector) -> Int {
        var hasher = Hasher()
        hasher.combine(ObjectIdentifier(type))
        hasher.combine(original)
        hasher.combine(swizzled)
        return hasher.finalize()
    }
}

private var swizzlingHistory = SwizzlingHistory()

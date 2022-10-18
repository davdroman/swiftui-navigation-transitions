@propertyWrapper
public struct OptionalWithDefault<Value> {
    public private(set) var projectedValue: Value? = nil

    private var defaultValue: Value

    public var wrappedValue: Value {
        get { projectedValue ?? defaultValue }
        set { projectedValue = newValue }
    }

    public init(wrappedValue: Value) {
        self.defaultValue = wrappedValue
    }
}

extension OptionalWithDefault: Equatable where Value: Equatable {}

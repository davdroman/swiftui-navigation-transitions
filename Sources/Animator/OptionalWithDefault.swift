@propertyWrapper
public struct OptionalWithDefault<Value> {
	public var projectedValue: Self { self }

	public private(set) var value: Value? = nil
	public private(set) var defaultValue: Value

	public var wrappedValue: Value {
		get { value ?? defaultValue }
		set { value = newValue }
	}

	public init(wrappedValue: Value) {
		self.defaultValue = wrappedValue
	}
}

extension OptionalWithDefault: Equatable where Value: Equatable {}

extension OptionalWithDefault {
	func assign<Root: AnyObject>(to root: Root, _ valueKeyPath: ReferenceWritableKeyPath<Root, Value>, force: Bool) {
		assign(force: force) {
			root[keyPath: valueKeyPath] = $0
		}
	}

	func assign(force: Bool, handler: (Value) -> Void) {
		if let value = force ? wrappedValue : value {
			handler(value)
		}
	}
}

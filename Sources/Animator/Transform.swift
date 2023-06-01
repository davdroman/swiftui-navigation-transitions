import UIKit

@dynamicMemberLookup
public struct Transform: Equatable {
	fileprivate var transform: CATransform3D

	public subscript<T>(dynamicMember keyPath: WritableKeyPath<CATransform3D, T>) -> T {
		get { transform[keyPath: keyPath] }
		set { transform[keyPath: keyPath] = newValue }
	}

	init(_ transform: CATransform3D) {
		self.transform = transform
	}
}

extension OptionalWithDefault where Value == Transform {
	func assign(to uiView: UIView, force: Bool) {
		self.assign(force: force) {
			if let transform = $0.transform.affineTransform {
				uiView.transform = transform
			} else {
				uiView.transform3D = $0.transform
			}
		}
	}
}

extension CATransform3D {
	var affineTransform: CGAffineTransform? {
		guard CATransform3DIsAffine(self) else {
			return nil
		}
		return CATransform3DGetAffineTransform(self)
	}
}

@_spi(package)
extension CATransform3D: Equatable {
	@inlinable
	public static func == (lhs: Self, rhs: Self) -> Bool {
		CATransform3DEqualToTransform(lhs, rhs)
	}
}

extension Transform {
	public static var identity: Self {
		.init(.identity)
	}

	public mutating func translate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
		transform = transform.translated(x: x, y: y, z: z)
	}

	public mutating func scale(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) {
		transform = transform.scaled(x: x, y: y, z: z)
	}

	public mutating func scale(_ s: CGFloat) {
		transform = transform.scaled(x: s, y: s, z: s)
	}

	public mutating func rotate(by angle: CGFloat, x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
		transform = transform.rotated(by: angle, x: x, y: y, z: z)
	}

	public func concatenated(with other: Self) -> Self {
		.init(transform.concatenated(with: other.transform))
	}
}

extension CATransform3D {
	@inlinable
	static var identity: Self {
		CATransform3DIdentity
	}

	@inlinable
	func translated(x: CGFloat, y: CGFloat, z: CGFloat) -> CATransform3D {
		CATransform3DTranslate(self, x, y, z)
	}

	@inlinable
	func scaled(x: CGFloat, y: CGFloat, z: CGFloat) -> CATransform3D {
		CATransform3DScale(self, x, y, z)
	}

	@inlinable
	func scaled(_ s: CGFloat) -> CATransform3D {
		CATransform3DScale(self, s, s, s)
	}

	@inlinable
	func rotated(by angle: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat) -> CATransform3D {
		CATransform3DRotate(self, angle, x, y, z)
	}

	@inlinable
	func concatenated(with other: CATransform3D) -> CATransform3D {
		CATransform3DConcat(self, other)
	}
}

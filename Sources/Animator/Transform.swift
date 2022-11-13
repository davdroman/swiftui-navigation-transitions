import UIKit

@dynamicMemberLookup
public struct Transform {
    private var transform: CATransform3D

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<CATransform3D, T>) -> T {
        get { transform[keyPath: keyPath] }
        set { transform[keyPath: keyPath] = newValue }
    }

    init(_ transform: CATransform3D) {
        self.transform = transform
    }

    func assignToUIView(_ uiView: UIView) {
        if let transform = transform.affineTransform {
            uiView.transform = transform
        } else {
            uiView.transform3D = transform
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

extension Transform: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        CATransform3DEqualToTransform(lhs.transform, rhs.transform)
    }
}

extension Transform {
    public static var identity: Self {
        .init(CATransform3DIdentity)
    }

    public var isIdentity: Bool {
        CATransform3DIsIdentity(transform)
    }
}

extension Transform {
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
}

extension CATransform3D {
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
}

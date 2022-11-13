import QuartzCore

@_spi(CATransform3DExtensions)
extension CATransform3D {
//    init(_ transform: CGAffineTransform) {
//        self = CATransform3DMakeAffineTransform(transform)
//    }

    public init(tx: CGFloat = 0, ty: CGFloat = 0, tz: CGFloat = 0) {
        self = CATransform3DMakeTranslation(tx, ty, tz)
    }

    public init(scale: CGFloat) {
        self = CATransform3DMakeScale(scale, scale, scale)
    }

    public init(sx: CGFloat = 1, sy: CGFloat = 1, sz: CGFloat = 1) {
        self = CATransform3DMakeScale(sx, sy, sz)
    }

    public init(angle: CGFloat, x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
        self = CATransform3DMakeRotation(angle, x, y, z)
    }
}

// MARK: Bridged properties

@_spi(CATransform3DExtensions)
extension CATransform3D {
    public static var identity: CATransform3D { return CATransform3DIdentity }

    public var isIdentity: Bool {
        CATransform3DIsIdentity(self)
    }

//    var affineTransform: CGAffineTransform? {
//        if !CATransform3DIsAffine(self) { return nil }
//        return CATransform3DGetAffineTransform(self)
//    }
}

// MARK: Transformations

@_spi(CATransform3DExtensions)
extension CATransform3D {

    @inlinable
    public func translated(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> CATransform3D {
        CATransform3DTranslate(self, x, y, z)
    }

    @inlinable
    public func scaled(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> CATransform3D {
        CATransform3DScale(self, x, y, z)
    }

    @inlinable
    public func scaled(_ s: CGFloat) -> CATransform3D {
        CATransform3DScale(self, s, s, s)
    }

    @inlinable
    public func rotated(by angle: CGFloat, x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> CATransform3D {
        CATransform3DRotate(self, angle, x, y, z)
    }

//    func concatenated(transform: CATransform3D) -> CATransform3D {
//        return CATransform3DConcat(self, transform)
//    }
}

@_spi(CATransform3DExtensions)
extension CATransform3D {
    public mutating func translate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
        self = self.translated(x: x, y: y, z: z)
    }

    public mutating func scale(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) {
        self = self.scaled(x: x, y: y, z: z)
    }

    public mutating func scale(_ s: CGFloat) {
        self = self.scaled(s)
    }

    public mutating func rotate(by angle: CGFloat, x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
        self = self.rotated(by: angle, x: x, y: y, z: z)
    }
}

@_spi(CATransform3DExtensions)
extension CATransform3D: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        CATransform3DEqualToTransform(lhs, rhs)
    }
}

//prefix func -(t: CATransform3D) -> CATransform3D {
//    return t.inverted
//}
//
//func +(lhs: CATransform3D, rhs: CATransform3D) -> CATransform3D {
//    return lhs.concatenated(rhs)
//}
//
//func -(lhs: CATransform3D, rhs: CATransform3D) -> CATransform3D {
//    return lhs + -rhs
//}
//
//func +(lhs: CGAffineTransform, rhs: CATransform3D) -> CATransform3D {
//    return CATransform3D(lhs) + rhs
//}
//
//func -(lhs: CGAffineTransform, rhs: CATransform3D) -> CATransform3D {
//    return CATransform3D(lhs) - rhs
//}
//
//func +(lhs: CATransform3D, rhs: CGAffineTransform) -> CATransform3D {
//    return lhs + CATransform3D(rhs)
//}
//
//func -(lhs: CATransform3D, rhs: CGAffineTransform) -> CATransform3D {
//    return lhs - CATransform3D(lhs)
//}
//
//func += (inout lhs: CATransform3D, rhs: CATransform3D) { lhs = lhs + rhs }
//func += (inout lhs: CATransform3D, rhs: CGAffineTransform) { lhs = lhs + rhs }
//func -= (inout lhs: CATransform3D, rhs: CATransform3D) { lhs = lhs - rhs }
//func -= (inout lhs: CATransform3D, rhs: CGAffineTransform) { lhs = lhs - rhs }

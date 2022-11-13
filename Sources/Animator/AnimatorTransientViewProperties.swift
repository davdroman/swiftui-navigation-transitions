import UIKit

/// Defines the allowed mutable properties in a transient view throughout each stage of the transition.
public struct AnimatorTransientViewProperties: Equatable {
    public typealias Layer = AnimatorTransientViewLayerProperties

    /// A proxy for `UIView.alpha`.
    @OptionalWithDefault
    public var alpha: CGFloat

    /// A proxy for `UIView.transform`.
    @OptionalWithDefault
    public var transform: CGAffineTransform

    /// A proxy for `UIView.layer`.
    @OptionalWithDefault
    public var layer: Layer

    func assignToUIView(_ uiView: UIView) {
        $alpha.assignTo(uiView, \.alpha)
        $transform.assignTo(uiView, \.transform)
        $layer?.assignToUIView(uiView)
    }
}

extension AnimatorTransientViewProperties {
    /// Convenience property for `CGAffineTransform` translation component.
    public var translation: CGVector {
        get { transform.translation }
        set { transform.translation = newValue }
    }

    /// Convenience property for `CGAffineTransform` scale component.
    public var scale: CGSize {
        get { transform.scale }
        set { transform.scale = newValue }
    }

    /// Convenience property for `CGAffineTransform` rotation component.
    public var rotation: CGFloat {
        get { transform.rotation }
        set { transform.rotation = newValue }
    }
}

extension CGAffineTransform {
    var translation: CGVector {
        get { components.translation }
        set { components.translation = newValue }
    }

    var scale: CGSize {
        get { components.scale }
        set { components.scale = newValue }
    }

    var rotation: CGFloat {
        get { components.rotation }
        set { components.rotation = newValue }
    }

    private typealias Components = _CGAffineTransformComponents

    private var components: Components {
        get {
            Components(
                scale: CGSize(
                    width: sqrt(pow(a, 2) + pow(c, 2)),
                    height: sqrt(pow(b, 2) + pow(d, 2))
                ),
                rotation: atan2(b, a),
                translation: CGVector(dx: tx, dy: ty)
            )
        }
        set {
            guard components != newValue else { return }
            self = CGAffineTransform(newValue)
        }
    }

    private init(_ components: Components) {
        self = .identity
            .translatedBy(x: components.translation.dx, y: components.translation.dy)
            .scaledBy(x: components.scale.width, y: components.scale.height)
            .rotated(by: components.rotation)
    }
}

public struct _CGAffineTransformComponents: Equatable {
    /// Scaling in X and Y dimensions.
    public var scale: CGSize

    /// Rotation angle in radians.
    public var rotation: Double

    /// Displacement from the origin (ty, ty).
    public var translation: CGVector

    public init(scale: CGSize, rotation: Double, translation: CGVector) {
        self.scale = scale
        self.rotation = rotation
        self.translation = translation
    }
}

import UIKit

/// Defines the allowed mutable properties in a transient view throughout each stage of the transition.
public struct AnimatorTransientViewLayerProperties: Equatable {
    /// A proxy for `CALayer.transform`.
    @OptionalWithDefault
    public var transform: CATransform3D
    /// A proxy for `CALayer.zPosition`.
    @OptionalWithDefault
    public var zPosition: CGFloat

    func assignToUIView(_ uiView: UIView) {
        $transform.assignTo(uiView, \.layer.transform)
        $zPosition.assignTo(uiView, \.layer.zPosition)
    }
}

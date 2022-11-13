import UIKit

/// Defines the allowed mutable properties in a transient view throughout each stage of the transition.
public struct AnimatorTransientViewProperties: Equatable {
    /// A proxy for `UIView.alpha`.
    @OptionalWithDefault
    public var alpha: CGFloat

    /// A proxy for `UIView.transform` or `UIView.transform3D`.
    @OptionalWithDefault
    public var transform: Transform

    /// A proxy for `UIView.layer.zPosition`.
    @OptionalWithDefault
    public var zPosition: CGFloat

    func assignToUIView(_ uiView: UIView) {
        $alpha.assignTo(uiView, \.alpha)
        $transform?.assignToUIView(uiView)
        $zPosition.assignTo(uiView, \.layer.zPosition)
    }
}

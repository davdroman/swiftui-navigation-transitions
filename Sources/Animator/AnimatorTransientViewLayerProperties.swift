import UIKit

/// Defines the allowed mutable properties in a transient view throughout each stage of the transition.
public struct AnimatorTransientViewLayerProperties: Equatable {
    @OptionalWithDefault
    public var zPosition: CGFloat

    func assignToUIView(_ uiView: UIView) {
        $zPosition.assignTo(uiView, \.layer.zPosition)
    }
}

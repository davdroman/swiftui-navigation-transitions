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
}

extension AnimatorTransientViewProperties {
	static let `default` = Self(
		alpha: 1,
		transform: .identity,
		zPosition: 0
	)

	init(of uiView: UIView) {
		self.init(
			alpha: uiView.alpha,
			transform: .init(uiView.transform3D),
			zPosition: uiView.layer.zPosition
		)
	}

	func assignToUIView(_ uiView: UIView, force: Bool) {
		$alpha.assign(to: uiView, \.alpha, force: force)
		$transform.assign(force: force) { $0.assignToUIView(uiView) }
		$zPosition.assign(to: uiView, \.layer.zPosition, force: force)
	}
}

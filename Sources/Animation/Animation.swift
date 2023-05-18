import UIKit

public struct Animation {
	static var defaultDuration: Double { 0.35 }

	@_spi(package) public var duration: Double
	@_spi(package) public let timingParameters: UITimingCurveProvider

	// Initializes a new `Animation` instance.
	///
	/// - Parameters:
	///   - duration: The duration of the animation.
	///   - timingParameters: The timing parameters for the animation.
	public init(duration: Double, timingParameters: UITimingCurveProvider) {
		self.duration = duration
		self.timingParameters = timingParameters
	}

	/// Initializes a new `Animation` instance with a specified curve.
	///
	/// - Parameters:
	///   - duration: The duration of the animation.
	///   - curve: The curve for the animation.
	public init(duration: Double, curve: UIView.AnimationCurve) {
		self.init(duration: duration, timingParameters: UICubicTimingParameters(animationCurve: curve))
	}
}

extension Animation {
	public func speed(_ speed: Double) -> Self {
		var copy = self
		copy.duration /= speed
		return copy
	}
}

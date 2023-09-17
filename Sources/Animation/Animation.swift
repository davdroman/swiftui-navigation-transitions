import UIKit

public struct Animation {
	static var defaultDuration: Double { 0.35 }

	package var duration: Double
    package let timingParameters: UITimingCurveProvider

	init(duration: Double, timingParameters: UITimingCurveProvider) {
		self.duration = duration
		self.timingParameters = timingParameters
	}

	init(duration: Double, curve: UIView.AnimationCurve) {
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

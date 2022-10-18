import UIKit

public struct Animation {
    @_spi(package)public
    static var defaultDuration: Double { 0.35 }

    @_spi(package)public
    var duration: Double
    @_spi(package)public
    let timingParameters: UITimingCurveProvider

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

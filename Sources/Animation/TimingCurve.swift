import UIKit

extension Animation {
    public static func timingCurve(
        _ c0x: Double,
        _ c0y: Double,
        _ c1x: Double,
        _ c1y: Double,
        duration: Double
    ) -> Self {
        .init(
            duration: duration,
            timingParameters: UICubicTimingParameters(
                controlPoint1: CGPoint(x: c0x, y: c0y),
                controlPoint2: CGPoint(x: c1x, y: c1y)
            )
        )
    }

    public static func timingCurve(
        _ c0x: Double,
        _ c0y: Double,
        _ c1x: Double,
        _ c1y: Double
    ) -> Self {
        .timingCurve(c0x, c0y, c1x, c1y, duration: defaultDuration)
    }
}

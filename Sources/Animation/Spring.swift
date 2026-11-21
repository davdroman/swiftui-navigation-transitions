import Foundation

// `blendDuration` has no effect: a navigation transition has no previous animation to blend with.
extension Animation {
	public static func spring(duration: Double = 0.5, bounce: Double = 0.0, blendDuration: Double = 0) -> Self {
		.spring(response: duration, dampingFraction: springDampingFraction(bounce: bounce), blendDuration: blendDuration)
	}

	@_disfavoredOverload
	public static func spring(
		response: Double = 0.5,
		dampingFraction: Double = 0.825,
		blendDuration: Double = 0,
	) -> Self {
		let stiffness = springStiffness(response: response)
		return .init(spring: SpringTiming(
			mass: 1,
			stiffness: stiffness,
			damping: springDamping(fraction: dampingFraction, stiffness: stiffness),
			style: .spring,
		))
	}

	public static var spring: Self {
		.spring()
	}

	@_disfavoredOverload
	public static func interactiveSpring(
		response: Double = 0.15,
		dampingFraction: Double = 0.86,
		blendDuration: Double = 0.25,
	) -> Self {
		.spring(response: response, dampingFraction: dampingFraction, blendDuration: blendDuration)
	}

	public static func interactiveSpring(
		duration: Double = 0.15,
		extraBounce: Double = 0.0,
		blendDuration: Double = 0.25,
	) -> Self {
		.spring(duration: duration, bounce: 0.15 + extraBounce, blendDuration: blendDuration)
	}

	public static var interactiveSpring: Self {
		.interactiveSpring()
	}

	public static func smooth(duration: Double = 0.5, extraBounce: Double = 0.0) -> Self {
		.spring(duration: duration, bounce: extraBounce)
	}

	public static var smooth: Self {
		.smooth()
	}

	public static func snappy(duration: Double = 0.5, extraBounce: Double = 0.0) -> Self {
		.spring(duration: duration, bounce: 0.15 + extraBounce)
	}

	public static var snappy: Self {
		.snappy()
	}

	public static func bouncy(duration: Double = 0.5, extraBounce: Double = 0.0) -> Self {
		.spring(duration: duration, bounce: 0.3 + extraBounce)
	}

	public static var bouncy: Self {
		.bouncy()
	}
}

/// SwiftUI's conversions from a spring's response, damping fraction, and bounce, for a mass of 1.
extension Animation {
	static func springStiffness(response: Double) -> Double {
		if response <= 0 {
			.infinity
		} else {
			pow(2 * .pi / response, 2)
		}
	}

	static func springDamping(fraction: Double, stiffness: Double) -> Double {
		2 * stiffness.squareRoot() * fraction
	}

	static func springDampingFraction(bounce: Double) -> Double {
		if bounce <= -1 {
			.infinity
		} else if bounce < 0 {
			1 / (bounce + 1)
		} else {
			1 - min(bounce, 1)
		}
	}
}

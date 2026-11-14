import UIKit

@MainActor
extension Animation {
	public static func spring(duration: Double = 0.5, bounce: Double = 0.0) -> Self {
		.spring(response: duration, dampingFraction: springDampingFraction(bounce: bounce))
	}

	@_disfavoredOverload
	public static func spring(response: Double = 0.5, dampingFraction: Double = 0.825) -> Self {
		.springTiming(response: response, dampingFraction: dampingFraction, initialVelocity: 0)
	}

	public static var spring: Self {
		.spring()
	}

	@_disfavoredOverload
	public static func interactiveSpring(response: Double = 0.15, dampingFraction: Double = 0.86) -> Self {
		.spring(response: response, dampingFraction: dampingFraction)
	}

	public static func interactiveSpring(duration: Double = 0.15, extraBounce: Double = 0.0) -> Self {
		.spring(duration: duration, bounce: 0.15 + extraBounce)
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

extension Animation {
	/// A spring with SwiftUI's response and damping fraction semantics.
	static func springTiming(response: Double, dampingFraction: Double, initialVelocity: Double) -> Self {
		let stiffness = springStiffness(response: response)
		return .init(
			mass: 1,
			stiffness: stiffness,
			damping: 2 * stiffness.squareRoot() * dampingFraction,
			initialVelocity: initialVelocity,
		)
	}

	static func springStiffness(response: Double) -> Double {
		if response <= 0 {
			.infinity
		} else {
			pow(2 * .pi / response, 2)
		}
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

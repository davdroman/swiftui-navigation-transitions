import CoreGraphics
import Foundation
import simd

/// The motion of a spring that starts at rest and is damped past critical damping, as a fraction of the distance it
/// travels.
///
/// Time is measured in units of the reciprocal of the spring's angular frequency, so the damping ratio alone decides
/// the shape of the motion.
struct OverdampedSpring {
	/// The fraction of the distance within which the spring counts as settled.
	static var settlingThreshold: Double { 0.001 }

	/// Normalized times of the samples the cubic approximation is fitted to, denser near both ends.
	private static let sampleProgress: [Double] = (1..<sampleCount).map {
		(1 - cos(.pi * Double($0) / Double(sampleCount))) / 2
	}

	private static var sampleCount: Int { 25 }

	let dampingRatio: Double
	let settlingTime: Double
	private let slowRate: Double
	private let fastRate: Double

	init(dampingRatio: Double) {
		let root = (dampingRatio * dampingRatio - 1).squareRoot()
		self.dampingRatio = dampingRatio
		// Equal to `dampingRatio - root`, without the cancellation at large damping ratios.
		self.slowRate = 1 / (dampingRatio + root)
		self.fastRate = dampingRatio + root
		self.settlingTime = Self.settlingTime(slowRate: slowRate, fastRate: fastRate)
	}

	func progress(at time: Double) -> Double {
		Self.progress(at: time, slowRate: slowRate, fastRate: fastRate)
	}

	private static func progress(at time: Double, slowRate: Double, fastRate: Double) -> Double {
		1 - (fastRate * exp(-slowRate * time) - slowRate * exp(-fastRate * time)) / (fastRate - slowRate)
	}

	private static func settlingTime(slowRate: Double, fastRate: Double) -> Double {
		// The spring approaches its target without overshooting, so it settles the first time it's within the threshold.
		func isSettled(at time: Double) -> Bool {
			1 - progress(at: time, slowRate: slowRate, fastRate: fastRate) <= settlingThreshold
		}
		var unsettled = 0.0
		var settled = 1.0
		while !isSettled(at: settled) {
			unsettled = settled
			settled *= 2
		}
		for _ in 0..<50 {
			let time = (unsettled + settled) / 2
			if isSettled(at: time) {
				settled = time
			} else {
				unsettled = time
			}
		}
		return settled
	}

	private var sampleTargets: [Double] {
		Self.sampleProgress.map { progress(at: $0 * settlingTime) }
	}

	/// The largest deviation of a critically damped spring of the same angular frequency from this motion.
	var criticallyDampedError: Double {
		zip(Self.sampleProgress, sampleTargets)
			.map { x, target in
				let time = x * settlingTime
				return abs(1 - (1 + time) * exp(-time) - target)
			}
			.max() ?? 0
	}

	/// A cubic Bézier timing curve spanning `settlingTime` that approximates the motion, and its largest deviation from
	/// it.
	///
	/// Fits the curve's control points by least squares with Levenberg–Marquardt, reweighting the samples by their
	/// deviation between rounds (Lawson's method) to approach the smallest largest deviation.
	func cubicApproximation() -> (controlPoint1: CGPoint, controlPoint2: CGPoint, error: Double) {
		let targets = sampleTargets
		var curve = CubicCurve(x1: 0.2, y1: 0.6, x2: 0.1, y2: 1)
		var fit = curve.fit(to: targets, at: Self.sampleProgress)
		var weights = [Double](repeating: 1, count: targets.count)

		for _ in 0..<4 {
			var cost = fit.cost(weights: weights)
			var damping = 1e-3
			for _ in 0..<30 {
				var hessian = simd_double4x4()
				var gradient = SIMD4<Double>()
				for (index, (residual, jacobian)) in zip(fit.residuals, fit.jacobians).enumerated() {
					let weighted = weights[index] * jacobian
					hessian += simd_double4x4(
						weighted * jacobian.x,
						weighted * jacobian.y,
						weighted * jacobian.z,
						weighted * jacobian.w,
					)
					gradient += weighted * residual
				}
				var improved = false
				while damping < 1e8 {
					var system = hessian
					for index in 0..<4 {
						system[index][index] += damping * (hessian[index][index] + 1e-12)
					}
					let candidate = curve.moved(by: -(system.inverse * gradient))
					let candidateFit = candidate.fit(to: targets, at: Self.sampleProgress)
					let candidateCost = candidateFit.cost(weights: weights)
					if candidateCost < cost {
						curve = candidate
						fit = candidateFit
						cost = candidateCost
						damping /= 3
						improved = true
						break
					}
					damping *= 4
				}
				if !improved {
					break
				}
			}

			let mean = zip(weights, fit.residuals).map { $0 * abs($1) }.reduce(0, +) / Double(weights.count)
			guard mean > 0 else {
				break
			}
			weights = zip(weights, fit.residuals).map { max($0 * abs($1) / mean, 1e-6) }
		}

		return (
			CGPoint(x: curve.x1, y: curve.y1),
			CGPoint(x: curve.x2, y: curve.y2),
			fit.residuals.map(abs).max() ?? 0,
		)
	}
}

/// A cubic Bézier timing curve from (0, 0) to (1, 1).
private struct CubicCurve {
	var x1: Double
	var y1: Double
	var x2: Double
	var y2: Double

	struct Fit {
		var residuals: [Double]
		/// Derivatives of each residual with respect to `x1`, `y1`, `x2` and `y2`.
		var jacobians: [SIMD4<Double>]

		func cost(weights: [Double]) -> Double {
			zip(weights, residuals).map { $0 * $1 * $1 }.reduce(0, +)
		}
	}

	func moved(by step: SIMD4<Double>) -> Self {
		// Keeping both x coordinates within 0...1 keeps time moving forward along the curve.
		Self(
			x1: min(max(x1 + step.x, 0), 1),
			y1: y1 + step.y,
			x2: min(max(x2 + step.z, 0), 1),
			y2: y2 + step.w,
		)
	}

	func fit(to targets: [Double], at xs: [Double]) -> Fit {
		var fit = Fit(residuals: [], jacobians: [])
		for (x, target) in zip(xs, targets) {
			let t = parameter(atX: x)
			let basis1 = 3 * (1 - t) * (1 - t) * t
			let basis2 = 3 * (1 - t) * t * t
			let y = basis1 * y1 + basis2 * y2 + t * t * t
			// Moving an x control point shifts which parameter reaches `x`, which moves y along the curve's slope.
			let slope = Self.derivative(t, y1, y2) / max(Self.derivative(t, x1, x2), 1e-9)
			fit.residuals.append(y - target)
			fit.jacobians.append(SIMD4(-slope * basis1, basis1, -slope * basis2, basis2))
		}
		return fit
	}

	/// The curve parameter at which the curve reaches `x`, by Newton's method.
	private func parameter(atX x: Double) -> Double {
		var t = x
		for _ in 0..<8 {
			let error = Self.coordinate(t, x1, x2) - x
			t = min(max(t - error / max(Self.derivative(t, x1, x2), 1e-9), 0), 1)
		}
		return t
	}

	private static func coordinate(_ t: Double, _ p1: Double, _ p2: Double) -> Double {
		3 * (1 - t) * (1 - t) * t * p1 + 3 * (1 - t) * t * t * p2 + t * t * t
	}

	private static func derivative(_ t: Double, _ p1: Double, _ p2: Double) -> Double {
		3 * (1 - t) * (1 - t) * p1 + 6 * (1 - t) * t * (p2 - p1) + 3 * t * t * (1 - p2)
	}
}

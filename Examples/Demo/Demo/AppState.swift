import Foundation
import SwiftUINavigationTransitions

final class AppState: ObservableObject {
	enum Transition: CaseIterable, CustomStringConvertible, Hashable {
		case `default`
		case crossFade
		case slide
		case slideVertically
		case slideAndFadeIn
		case slideAndFadeOut
		case flip
		case flipVertically
		case swing
		case zoom
		case zoomAndSlide

		var description: String {
			switch self {
			case .default:
				return "Default"
			case .crossFade:
				return "Fade"
			case .slide:
				return "Slide"
			case .slideVertically:
				return "Slide Vertically"
			case .slideAndFadeIn:
				return "Slide + Fade In"
			case .slideAndFadeOut:
				return "Slide + Fade Out"
			case .flip:
				return "Flip"
			case .flipVertically:
				return "Flip Vertically"
			case .swing:
				return "Swing"
			case .zoom:
				return "Zoom"
			case .zoomAndSlide:
				return "Zoom + Slide"
			}
		}

		func callAsFunction() -> AnyNavigationTransition {
			switch self {
			case .default:
				return .default
			case .crossFade:
				return .fade(.cross)
			case .slide:
				return .slide
			case .slideVertically:
				return .slide(axis: .vertical)
			case .slideAndFadeIn:
				return .slide.combined(with: .fade(.in))
			case .slideAndFadeOut:
				return .slide.combined(with: .fade(.out))
			case .flip:
				return .flip
			case .flipVertically:
				return .flip(axis: .vertical)
			case .swing:
				return .swing
			case .zoom:
				return .zoom
			case .zoomAndSlide:
				return .zoom.combined(with: .slide)
			}
		}
	}

	enum Animation: CaseIterable, CustomStringConvertible, Hashable {
		case none
		case linear
		case easeInOut
		case spring

		var description: String {
			switch self {
			case .none:
				return "None"
			case .linear:
				return "Linear"
			case .easeInOut:
				return "Ease In Out"
			case .spring:
				return "Spring"
			}
		}

		func callAsFunction(
			duration: Duration,
			stiffness: Stiffness,
			damping: Damping
		) -> AnyNavigationTransition.Animation? {
			switch self {
			case .none:
				return .none
			case .linear:
				return .linear(duration: duration())
			case .easeInOut:
				return .easeInOut(duration: duration())
			case .spring:
				return .interpolatingSpring(stiffness: stiffness(), damping: damping())
			}
		}
	}

	enum Duration: CaseIterable, CustomStringConvertible, Hashable {
		case slow
		case medium
		case fast

		var description: String {
			switch self {
			case .slow:
				return "Slow"
			case .medium:
				return "Medium"
			case .fast:
				return "Fast"
			}
		}

		func callAsFunction() -> Double {
			switch self {
			case .slow:
				return 1
			case .medium:
				return 0.6
			case .fast:
				return 0.35
			}
		}
	}

	enum Stiffness: CaseIterable, CustomStringConvertible, Hashable {
		case low
		case medium
		case high

		var description: String {
			switch self {
			case .low:
				return "Low"
			case .medium:
				return "Medium"
			case .high:
				return "High"
			}
		}

		func callAsFunction() -> Double {
			switch self {
			case .low:
				return 300
			case .medium:
				return 120
			case .high:
				return 50
			}
		}
	}

	enum Damping: CaseIterable, CustomStringConvertible, Hashable {
		case low
		case medium
		case high
		case veryHigh

		var description: String {
			switch self {
			case .low:
				return "Low"
			case .medium:
				return "Medium"
			case .high:
				return "High"
			case .veryHigh:
				return "Very High"
			}
		}

		func callAsFunction() -> Double {
			switch self {
			case .low:
				return 20
			case .medium:
				return 25
			case .high:
				return 30
			case .veryHigh:
				return 50
			}
		}
	}

	enum Interactivity: CaseIterable, CustomStringConvertible, Hashable {
		case disabled
		case edgePan
		case pan

		var description: String {
			switch self {
			case .disabled:
				return "Disabled"
			case .edgePan:
				return "Edge Pan"
			case .pan:
				return "Pan"
			}
		}

		func callAsFunction() -> AnyNavigationTransition.Interactivity {
			switch self {
			case .disabled:
				return .disabled
			case .edgePan:
				return .edgePan
			case .pan:
				return .pan
			}
		}
	}

	@Published var transition: Transition = .slide

	@Published var animation: Animation = .spring
	@Published var duration: Duration = .fast
	@Published var stiffness: Stiffness = .low
	@Published var damping: Damping = .veryHigh

	@Published var interactivity: Interactivity = .edgePan

	@Published var isPresentingSettings: Bool = false
}

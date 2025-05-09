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
				"Default"
			case .crossFade:
				"Fade"
			case .slide:
				"Slide"
			case .slideVertically:
				"Slide Vertically"
			case .slideAndFadeIn:
				"Slide + Fade In"
			case .slideAndFadeOut:
				"Slide + Fade Out"
			case .flip:
				"Flip"
			case .flipVertically:
				"Flip Vertically"
			case .swing:
				"Swing"
			case .zoom:
				"Zoom"
			case .zoomAndSlide:
				"Zoom + Slide"
			}
		}

		func callAsFunction() -> AnyNavigationTransition {
			switch self {
			case .default:
				.default
			case .crossFade:
				.fade(.cross)
			case .slide:
				.slide
			case .slideVertically:
				.slide(axis: .vertical)
			case .slideAndFadeIn:
				.slide.combined(with: .fade(.in))
			case .slideAndFadeOut:
				.slide.combined(with: .fade(.out))
			case .flip:
				.flip
			case .flipVertically:
				.flip(axis: .vertical)
			case .swing:
				.swing
			case .zoom:
				.zoom
			case .zoomAndSlide:
				.zoom.combined(with: .slide)
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
				"None"
			case .linear:
				"Linear"
			case .easeInOut:
				"Ease In Out"
			case .spring:
				"Spring"
			}
		}

		func callAsFunction(
			duration: Duration,
			stiffness: Stiffness,
			damping: Damping
		) -> AnyNavigationTransition.Animation? {
			switch self {
			case .none:
				.none
			case .linear:
				.linear(duration: duration())
			case .easeInOut:
				.easeInOut(duration: duration())
			case .spring:
				.interpolatingSpring(stiffness: stiffness(), damping: damping())
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
				"Slow"
			case .medium:
				"Medium"
			case .fast:
				"Fast"
			}
		}

		func callAsFunction() -> Double {
			switch self {
			case .slow:
				1
			case .medium:
				0.6
			case .fast:
				0.35
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
				"Low"
			case .medium:
				"Medium"
			case .high:
				"High"
			}
		}

		func callAsFunction() -> Double {
			switch self {
			case .low:
				300
			case .medium:
				120
			case .high:
				50
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
				"Low"
			case .medium:
				"Medium"
			case .high:
				"High"
			case .veryHigh:
				"Very High"
			}
		}

		func callAsFunction() -> Double {
			switch self {
			case .low:
				20
			case .medium:
				25
			case .high:
				30
			case .veryHigh:
				50
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
				"Disabled"
			case .edgePan:
				"Edge Pan"
			case .pan:
				"Pan"
			}
		}

		func callAsFunction() -> AnyNavigationTransition.Interactivity {
			switch self {
			case .disabled:
				.disabled
			case .edgePan:
				.edgePan
			case .pan:
				.pan
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

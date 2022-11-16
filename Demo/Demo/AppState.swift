import Foundation
import NavigationTransitions

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

    struct Animation {
        enum Curve: CaseIterable, CustomStringConvertible, Hashable {
            case linear
            case easeInOut
            case spring

            var description: String {
                switch self {
                case .linear:
                    return "Linear"
                case .easeInOut:
                    return "Ease In Out"
                case .spring:
                    return "Spring"
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

        var curve: Curve
        var duration: Duration

        func callAsFunction() -> AnyNavigationTransition.Animation {
            switch curve {
            case .linear:
                return .linear(duration: duration())
            case .easeInOut:
                return .easeInOut(duration: duration())
            case .spring:
                return .interpolatingSpring(stiffness: 120, damping: 50)
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
    @Published var animation: Animation = .init(curve: .easeInOut, duration: .fast)
    @Published var interactivity: Interactivity = .edgePan

    @Published var isPresentingSettings: Bool = false
}

import Foundation
import NavigationTransitions

final class AppState: ObservableObject {
    enum Transition: CaseIterable, CustomStringConvertible, Hashable {
        case `default`
        case slide
        case crossFade
        case slideAndFade
        case moveVertically
        case swing

        var description: String {
            switch self {
            case .default:
                return "Default"
            case .slide:
                return "Slide"
            case .crossFade:
                return "Fade"
            case .slideAndFade:
                return "Slide + Fade"
            case .moveVertically:
                return "Slide Vertically"
            case .swing:
                return "Swing"
            }
        }

        func callAsFunction() -> AnyNavigationTransition {
            switch self {
            case .default:
                return .default
            case .slide:
                return .slide
            case .crossFade:
                return .fade(.cross)
            case .slideAndFade:
                return .slide.combined(with: .fade(.in))
            case .moveVertically:
                return .slide(axis: .vertical)
            case .swing:
                return .swing
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

        func callAsFunction() -> NavigationTransition.Animation {
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

        func callAsFunction() -> NavigationTransitionInteractivity {
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
    @Published var animation: Animation = .init(curve: .easeInOut, duration: .medium)
    @Published var interactivity: Interactivity = .edgePan

    @Published var isPresentingSettings: Bool = false
}

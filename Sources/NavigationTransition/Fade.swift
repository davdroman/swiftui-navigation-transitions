import AtomicTransition

extension NavigationTransition {
    public enum Fade {
        case `in`
        case out
        case cross
    }

    /// A transition that fades the pushed view in, fades the popped view out, or cross-fades both views.
    public static func fade(_ fade: Fade) -> Self {
        switch fade {
        case .in:
            return .asymmetric(
                push: .asymmetric(insertion: .opacity, removal: .identity),
                pop: .asymmetric(insertion: .identity, removal: .opacity)
            )
        case .out:
            return .asymmetric(
                push: .asymmetric(
                    insertion: .identity,
                    removal: .opacity.combined(with: .bringToFront)
                ),
                pop: .asymmetric(
                    insertion: .opacity.combined(with: .bringToFront),
                    removal: .identity
                )
            )
        case .cross:
            return .asymmetric(push: .opacity, pop: .opacity)
        }
    }
}

/// A transition that fades the pushed view in, fades the popped view out, or cross-fades both views.
public struct Fade: NavigationTransitionProtocol {
    public enum Style {
        case `in`
        case out
        case cross
    }

    private let style: Style

    public init(_ style: Style) {
        self.style = style
    }

    public var body: some NavigationTransitionProtocol {
        switch style {
        case .in:
            OnPush {
                OnInsertion {
                    Opacity()
                }
            }
            OnPop {
                OnRemoval {
                    Opacity()
                }
            }
        case .out:
            OnPush {
                OnRemoval {
                    BringToFront()
                    Opacity()
                }
            }
            OnPop {
                OnInsertion {
                    BringToFront()
                    Opacity()
                }
            }
        case .cross:
            OnPush {
                Opacity()
            }
            OnPop {
                Opacity()
            }
        }
    }
}

extension Fade: Hashable {}

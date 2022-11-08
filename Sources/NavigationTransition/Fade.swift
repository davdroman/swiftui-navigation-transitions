import AtomicTransition

extension AnyNavigationTransition {
    /// A transition that fades the pushed view in, fades the popped view out, or cross-fades both views.
    public static func fade(_ style: Fade.Style) -> Self {
        .init(Fade(style))
    }
}

/// A transition that fades the pushed view in, fades the popped view out, or cross-fades both views.
public struct Fade: NavigationTransition {
    public enum Style {
        case `in`
        case out
        case cross
    }

    private let style: Style

    public init(_ style: Style) {
        self.style = style
    }

    public var body: some NavigationTransition {
        switch style {
        case .in:
            Mirror {
                OnInsertion {
                    Opacity()
                }
            }
            OnPop {
                OnInsertion {
                    BringToFront()
                }
            }
        case .out:
            Mirror {
                OnRemoval {
                    Opacity()
                }
            }
            OnPush {
                OnRemoval {
                    BringToFront()
                }
            }
        case .cross:
            Mirror {
                Opacity()
            }
        }
    }
}

extension Fade: Hashable {}

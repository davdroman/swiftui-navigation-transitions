import AtomicTransition

extension AnyNavigationTransition {
	/// A transition that fades the pushed view in, fades the popped view out, or cross-fades both views.
	public static func fade(_ style: Fade.Style) -> Self {
		.init(Fade(style))
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
			MirrorPush {
				OnInsertion {
					ZPosition(1)
					Opacity()
				}
			}
		case .out:
			MirrorPush {
				OnRemoval {
					ZPosition(1)
					Opacity()
				}
			}
		case .cross:
			MirrorPush {
				Opacity()
			}
		}
	}
}

extension Fade: Hashable {}

import AtomicTransition
import SwiftUI

extension AnyNavigationTransition {
    /// A transition that moves both views in and out along the specified axis.
    ///
    /// This transition:
    /// - Pushes views right-to-left and pops views left-to-right when `axis` is `horizontal`.
    /// - Pushes views bottom-to-top and pops views top-to-bottom when `axis` is `vertical`.
    public static func slide(axis: Axis) -> Self {
        .init(Slide(axis: axis))
    }
}

extension AnyNavigationTransition {
    /// Equivalent to `slide(axis: .horizontal)`.
    @inlinable
    public static var slide: Self {
        .slide(axis: .horizontal)
    }
}

/// A transition that moves both views in and out along the specified axis.
///
/// This transition:
/// - Pushes views right-to-left and pops views left-to-right when `axis` is `horizontal`.
/// - Pushes views bottom-to-top and pops views top-to-bottom when `axis` is `vertical`.
public struct Slide: NavigationTransitionProtocol {
    private let axis: Axis

    public init(axis: Axis) {
        self.axis = axis
    }

    /// Equivalent to `Move(axis: .horizontal)`.
    @inlinable
    public init() {
        self.init(axis: .horizontal)
    }

    public var body: some NavigationTransitionProtocol {
        switch axis {
        case .horizontal:
            OnPush {
                OnInsertion {
                    Move(edge: .trailing)
                }
                OnRemoval {
                    Move(edge: .leading)
                }
            }
            OnPop {
                OnInsertion {
                    Move(edge: .leading)
                }
                OnRemoval {
                    Move(edge: .trailing)
                }
            }
        case .vertical:
            OnPush {
                OnInsertion {
                    Move(edge: .bottom)
                }
                OnRemoval {
                    Move(edge: .top)
                }
            }
            OnPop {
                OnInsertion {
                    Move(edge: .top)
                }
                OnRemoval {
                    Move(edge: .bottom)
                }
            }
        }
    }
}

extension Slide: Hashable {}

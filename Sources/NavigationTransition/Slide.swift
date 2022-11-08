import AtomicTransition
import SwiftUI

//extension NavigationTransition {
//    /// A transition that moves both views in and out along the specified axis.
//    ///
//    /// This transition:
//    /// - Pushes views right-to-left and pops views left-to-right when `axis` is `horizontal`.
//    /// - Pushes views bottom-to-top and pops views top-to-bottom when `axis` is `vertical`.
//    public static func move(axis: Axis) -> Self {
//        switch axis {
//        case .horizontal:
//            return .asymmetric(
//                push: .asymmetric(
//                    insertion: .move(edge: .trailing),
//                    removal: .move(edge: .leading)
//                ),
//                pop: .asymmetric(
//                    insertion: .move(edge: .leading),
//                    removal: .move(edge: .trailing)
//                )
//            )
//        case .vertical:
//            return .asymmetric(
//                push: .asymmetric(
//                    insertion: .move(edge: .bottom),
//                    removal: .move(edge: .top)
//                ),
//                pop: .asymmetric(
//                    insertion: .move(edge: .top),
//                    removal: .move(edge: .bottom)
//                )
//            )
//        }
//    }
//}
//
//extension NavigationTransition {
//    /// Equivalent to `move(axis: .horizontal)`.
//    @inlinable
//    public static var slide: Self {
//        .move(axis: .horizontal)
//    }
//}

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

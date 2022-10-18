import enum SwiftUI.Axis

extension NavigationTransition {
    /// A transition that moves both views in and out along the specified axis.
    ///
    /// This transition:
    /// - Pushes views right-to-left and pops views left-to-right when `axis` is `horizontal`.
    /// - Pushes views bottom-to-top and pops views top-to-bottom when `axis` is `vertical`.
    public static func move(axis: Axis) -> Self {
        switch axis {
        case .horizontal:
            return .asymmetric(
                push: .asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ),
                pop: .asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .trailing)
                )
            )
        case .vertical:
            return .asymmetric(
                push: .asymmetric(
                    insertion: .move(edge: .bottom),
                    removal: .move(edge: .top)
                ),
                pop: .asymmetric(
                    insertion: .move(edge: .top),
                    removal: .move(edge: .bottom)
                )
            )
        }
    }
}

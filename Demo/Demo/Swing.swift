import NavigationTransition
import SwiftUI

extension NavigationTransition {
    static var swing: Self {
        let angle = Angle(degrees: 70)
        let offset: CGFloat = 150
        let scale: CGFloat = 0.5

        return .move(axis: .horizontal).combined(
            with: .asymmetric(
                push: .asymmetric(
                    insertion: [.rotate(-angle), .offset(x: offset), .opacity, .scale(scale)].combined(),
                    removal: [.rotate(angle), .offset(x: -offset)].combined()
                ),
                pop: .asymmetric(
                    insertion: [.rotate(angle), .offset(x: -offset), .opacity, .scale(scale), .bringToFront].combined(),
                    removal: [.rotate(-angle), .offset(x: offset)].combined()
                )
            )
        )
    }
}

extension Angle {
    static prefix func - (_ rhs: Self) -> Self {
        .init(degrees: -rhs.degrees)
    }
}

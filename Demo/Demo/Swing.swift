import NavigationTransition
import SwiftUI

extension NavigationTransition {
    // complex transitions start getting a little trickier to read clearly...
    // maybe good motivation to introduce result builder syntax
    // something like:
    //
    // Move(axis: .horizontal)
    // OnPush {
    //     OnInsertion {
    //         Rotate(-angle)
    //         Offset(x: 150)
    //         Opacity()
    //         Scale(0.5)
    //     }
    //     OnRemoval {
    //         ...
    //     }
    // }
    // OnPop {
    //     ...
    // }
    //
    // neat!
    static var swing: Self {
        let angle = Angle(degrees: 70)
        let offset: CGFloat = 150
        return .move(axis: .horizontal).combined(
            with: .asymmetric(
                push: .asymmetric(
                    insertion: [.rotate(-angle), .offset(x: offset), .opacity, .scale(0.5)].combined(),
                    removal: [.rotate(angle), .offset(x: -offset)].combined()
                ),
                pop: .asymmetric(
                    insertion: [.rotate(angle), .offset(x: -offset), .opacity, .scale(0.5), .bringToFront].combined(),
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

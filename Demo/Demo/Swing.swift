import NavigationTransition
import SwiftUI

extension AnyNavigationTransition {
    static var swing: Self {
        .init(Swing())
    }
}

struct Swing: NavigationTransitionProtocol {
    var body: some NavigationTransitionProtocol {
        let angle = Angle(degrees: 70)
        let offset: CGFloat = 150
        let scale: CGFloat = 0.5

        Slide(axis: .horizontal)
        OnPush {
            OnInsertion {
                Rotate(-angle)
                Offset(x: offset)
                Opacity()
                Scale(scale)
            }
            OnRemoval {
                Rotate(angle)
                Offset(x: -offset)
            }
        }
        OnPop {
            OnInsertion {
                Rotate(angle)
                Offset(x: -offset)
                Opacity()
                Scale(scale)
                BringToFront()
            }
            OnRemoval {
                Rotate(-angle)
                Offset(x: offset)
            }
        }
    }
}

extension Angle {
    static prefix func - (_ rhs: Self) -> Self {
        .init(degrees: -rhs.degrees)
    }
}

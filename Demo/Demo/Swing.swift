import NavigationTransition
import SwiftUI

extension AnyNavigationTransition {
    static var swing: Self {
        .init(Swing())
    }
}

struct Swing: NavigationTransition {
    var body: some NavigationTransition {
        let angle = Angle(degrees: 70)
        let offset: CGFloat = 150

        Slide(axis: .horizontal)
        MirrorPush {
            OnInsertion {
                Rotate(-angle)
                Offset(x: offset)
                Opacity()
                Scale(0.5)
            }
            OnRemoval {
                Rotate(angle)
                Offset(x: -offset)
            }
        }
        OnPop {
            OnRemoval {
                SendToBack()
            }
        }
    }
}

extension Angle {
    static prefix func - (_ rhs: Self) -> Self {
        .init(degrees: -rhs.degrees)
    }
}

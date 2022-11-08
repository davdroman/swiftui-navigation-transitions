import NavigationTransition
import SwiftUI

extension AnyNavigationTransition {
    static var swing: Self {
        .init(Swing())
    }
}

struct Swing: NavigationTransition {
    var body: some NavigationTransition {
        let angle = 70.0
        let offset = 150.0

        Slide(axis: .horizontal)
        MirrorPush {
            OnInsertion {
                Rotate(.degrees(-angle))
                Offset(x: offset)
                Opacity()
                Scale(0.5)
            }
            OnRemoval {
                Rotate(.degrees(angle))
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

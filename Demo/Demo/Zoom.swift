import NavigationTransition
import SwiftUI

extension AnyNavigationTransition {
    static var zoom: Self {
        .init(Zoom())
    }
}

struct Zoom: NavigationTransition {
    var body: some NavigationTransition {
        Slide(axis: .horizontal)
        MirrorPush {
            Scale(0.5)
        }
    }
}

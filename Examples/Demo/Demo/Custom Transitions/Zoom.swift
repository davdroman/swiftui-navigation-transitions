import NavigationTransition
import SwiftUI

extension AnyNavigationTransition {
	static var zoom: Self {
		.init(Zoom())
	}
}

struct Zoom: NavigationTransitionProtocol {
	var body: some NavigationTransitionProtocol {
		MirrorPush {
			Scale(0.5)
			OnInsertion {
				ZPosition(1)
				Opacity()
			}
		}
	}
}

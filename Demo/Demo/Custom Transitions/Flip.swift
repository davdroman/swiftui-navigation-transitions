import NavigationTransition
import SwiftUI

extension AnyNavigationTransition {
	static func flip(axis: Axis) -> Self {
		.init(Flip(axis: axis))
	}

	static var flip: Self {
		.flip(axis: .horizontal)
	}
}

struct Flip: NavigationTransition {
	var axis: Axis

	var body: some NavigationTransition {
		MirrorPush {
			Rotate3D(.degrees(180), axis: axis == .horizontal ? (x: 1, y: 0, z: 0) : (x: 0, y: 1, z: 0))
		}
	}
}

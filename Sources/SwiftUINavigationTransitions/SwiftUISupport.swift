public import SwiftUI
public import UIKitNavigationTransitions
@_spi(Advanced) import SwiftUIIntrospect

extension View {
	@MainActor
	public func customNavigationTransition(
		_ transition: CustomNavigationTransition,
		interactivity: CustomNavigationTransition.Interactivity = .default,
	) -> some View {
		self.introspect(
			.navigationView(style: .stack),
			on: .iOS(.v13...), .tvOS(.v13...), .visionOS(.v1...),
			scope: [.receiver, .ancestor],
		) { controller in
			controller.setNavigationTransition(transition, interactivity: interactivity)
		}
	}
}

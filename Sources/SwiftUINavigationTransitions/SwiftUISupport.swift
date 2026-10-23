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
			.navigationStack,
			on: .iOS(.v16...), .tvOS(.v16...), .visionOS(.v1...),
			scope: [.receiver, .ancestor],
		) { controller in
			controller.setNavigationTransition(transition, interactivity: interactivity)
		}
	}
}

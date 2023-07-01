import SwiftUI
@_implementationOnly @_spi(Advanced) import SwiftUIIntrospect

extension View {
	@ViewBuilder
	public func navigationTransition(
		_ transition: AnyNavigationTransition,
		interactivity: AnyNavigationTransition.Interactivity = .default
	) -> some View {
		self.introspect(
			.navigationView(style: .stack),
			on: .iOS(.v13...), .tvOS(.v13...),
			scope: [.receiver, .ancestor]
		) { controller in
			controller.setNavigationTransition(transition, interactivity: interactivity)
		}
	}
}

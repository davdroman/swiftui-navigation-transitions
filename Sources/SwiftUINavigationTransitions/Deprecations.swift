public import SwiftUI
public import UIKitNavigationTransitions

extension View {
	@MainActor
	@_disfavoredOverload
	@available(*, deprecated, renamed: "customNavigationTransition(_:interactivity:)")
	public func navigationTransition(
		_ transition: CustomNavigationTransition,
		interactivity: CustomNavigationTransition.Interactivity = .default,
	) -> some View {
		customNavigationTransition(transition, interactivity: interactivity)
	}
}

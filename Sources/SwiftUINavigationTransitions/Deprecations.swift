public import SwiftUI

@available(*, deprecated, renamed: "customNavigationTransition(_:interactivity:)")
@MainActor
extension View {
	@_disfavoredOverload
	public func navigationTransition(
		_ transition: CustomNavigationTransition,
		interactivity: CustomNavigationTransition.Interactivity = .default,
	) -> some View {
		customNavigationTransition(transition, interactivity: interactivity)
	}
}

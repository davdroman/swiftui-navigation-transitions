import SwiftUI

@main
struct App: SwiftUI.App {
	#if !os(tvOS)
	init() {
		customizeNavigationBarAppearance()
		customizeTabBarAppearance()
	}

	// https://developer.apple.com/documentation/technotes/tn3106-customizing-uinavigationbar-appearance
	func customizeNavigationBarAppearance() {
		let customAppearance = UINavigationBarAppearance()

		customAppearance.configureWithOpaqueBackground()
		customAppearance.backgroundColor = .systemBackground

		let proxy = UINavigationBar.appearance()
		proxy.scrollEdgeAppearance = customAppearance
		proxy.compactAppearance = customAppearance
		proxy.standardAppearance = customAppearance
		if #available(iOS 15.0, tvOS 15, *) {
			proxy.compactScrollEdgeAppearance = customAppearance
		}
	}

	func customizeTabBarAppearance() {
		let customAppearance = UITabBarAppearance()

		customAppearance.configureWithOpaqueBackground()
		customAppearance.backgroundColor = .systemBackground

		let proxy = UITabBar.appearance()
		proxy.standardAppearance = customAppearance
		proxy.scrollEdgeAppearance = customAppearance
	}
	#endif

	var body: some Scene {
		WindowGroup {
			AppView()
		}
	}
}

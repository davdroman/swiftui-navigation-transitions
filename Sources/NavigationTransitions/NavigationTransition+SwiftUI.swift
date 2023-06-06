@_implementationOnly import SwiftUIIntrospect
import SwiftUI

// MARK: iOS 16

public struct NavigationSplitViewColumns: OptionSet {
	@available(iOS, introduced: 16, deprecated, message: "Use 'navigationTransition' modifier instead")
	public static let sidebar = Self(rawValue: 1)
	@available(iOS, introduced: 16, deprecated, message: "Use 'navigationTransition' modifier instead")
	public static let content = Self(rawValue: 1 << 1)
	@available(iOS, introduced: 16, deprecated, message: "Use 'navigationTransition' modifier instead")
	public static let detail = Self(rawValue: 1 << 2)

	@available(iOS, introduced: 16, deprecated, message: "Use 'navigationTransition' modifier instead")
	public static let compact = Self(rawValue: 1 << 3)

	@available(iOS, introduced: 16, deprecated, message: "Use 'navigationTransition' modifier instead")
	public static let all: Self = [compact, sidebar, content, detail]

	public let rawValue: Int8

	public init(rawValue: Int8) {
		self.rawValue = rawValue
	}
}

extension View {
	@available(iOS, introduced: 16, deprecated, renamed: "navigationTransition")
	@ViewBuilder
	public func navigationSplitViewTransition(
		_ transition: AnyNavigationTransition,
		forColumns columns: NavigationSplitViewColumns,
		interactivity: AnyNavigationTransition.Interactivity = .default
	) -> some View {
		self.navigationTransition(transition, interactivity: interactivity)
	}

	@available(iOS, introduced: 16, deprecated, renamed: "navigationTransition")
	@ViewBuilder
	public func navigationStackTransition(
		_ transition: AnyNavigationTransition,
		interactivity: AnyNavigationTransition.Interactivity = .default
	) -> some View {
		self.navigationTransition(transition, interactivity: interactivity)
	}
}

extension View {
	@ViewBuilder
	public func navigationTransition(
		_ transition: AnyNavigationTransition,
		interactivity: AnyNavigationTransition.Interactivity = .default
	) -> some View {
		self.introspect(
			.navigationView(style: .stack),
			on: .iOS(.v13, .v14, .v15, .v16, .v17), .tvOS(.v13, .v14, .v15, .v16, .v17),
			scope: [.receiver, .ancestor]
		) { controller in
			controller.setNavigationTransition(transition, interactivity: interactivity)
		}
	}
}

// MARK: - Pre-iOS 16

@available(iOS, introduced: 13, deprecated, message: "Use 'navigationTransition' instead")
public struct NavigationViewColumns: OptionSet {
	@available(iOS, introduced: 13, deprecated, message: "Use 'navigationTransition' instead")
	public static let sidebar = Self(rawValue: 1)
	@available(iOS, introduced: 13, deprecated, message: "Use 'navigationTransition' instead")
	public static let detail = Self(rawValue: 1 << 1)

	@available(iOS, introduced: 13, deprecated, message: "Use 'navigationTransition' instead")
	public static let all: Self = [sidebar, detail]

	public let rawValue: Int8

	public init(rawValue: Int8) {
		self.rawValue = rawValue
	}
}

extension View {
	@available(iOS, introduced: 13, deprecated, renamed: "navigationTransition")
	@ViewBuilder
	public func navigationViewColumnTransition(
		_ transition: AnyNavigationTransition,
		forColumns columns: NavigationViewColumns,
		interactivity: AnyNavigationTransition.Interactivity = .default
	) -> some View {
		self.navigationTransition(transition, interactivity: interactivity)
	}

	@available(iOS, introduced: 13, deprecated, renamed: "navigationTransition")
	@ViewBuilder
	public func navigationViewStackTransition(
		_ transition: AnyNavigationTransition,
		interactivity: AnyNavigationTransition.Interactivity = .default
	) -> some View {
		self.navigationTransition(transition, interactivity: interactivity)
	}
}

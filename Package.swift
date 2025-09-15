// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "swiftui-navigation-transitions",
	platforms: [
		.iOS(.v13),
		.macCatalyst(.v13),
		.tvOS(.v13),
		.visionOS(.v1),
	],
	products: [
		.library(name: "SwiftUINavigationTransitions", targets: ["SwiftUINavigationTransitions"]),
		.library(name: "UIKitNavigationTransitions", targets: ["UIKitNavigationTransitions"]),
	],
	targets: [
		.target(name: "Animation"),

		.target(name: "Animator"),
		.testTarget(name: "AnimatorTests", dependencies: [
			"Animator",
			"TestUtils",
		]),

		.target(name: "AtomicTransition", dependencies: [
			"Animator",
		]),
		.testTarget(name: "AtomicTransitionTests", dependencies: [
			"AtomicTransition",
			"TestUtils",
		]),

		.target(name: "NavigationTransition", dependencies: [
			"Animation",
			"AtomicTransition",
			.product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
		]),

		.target(name: "UIKitNavigationTransitions", dependencies: [
			.product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
			"NavigationTransition",
			.product(name: "ObjCRuntimeTools", package: "objc-runtime-tools"),
			.product(name: "Once", package: "swift-once-macro"),
		]),

		.target(name: "SwiftUINavigationTransitions", dependencies: [
			"UIKitNavigationTransitions",
			.product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
		]),

		.target(name: "TestUtils", dependencies: [
			.product(name: "CustomDump", package: "swift-custom-dump"),
			.product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
			"SwiftUINavigationTransitions",
		]),
	],
	swiftLanguageModes: [.v5]
)

// MARK: Dependencies

package.dependencies = [
	.package(url: "https://github.com/davdroman/objc-runtime-tools", from: "0.1.0"),
	.package(url: "https://github.com/davdroman/swift-once-macro", from: "1.0.0"),
	.package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"), // dev
	.package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"),
	.package(url: "https://github.com/siteline/swiftui-introspect", "1.3.0"..<"27.0.0"),
]

for target in package.targets {
	target.swiftSettings = target.swiftSettings ?? []
	target.swiftSettings? += [
		.enableUpcomingFeature("ExistentialAny"),
		.enableUpcomingFeature("InternalImportsByDefault"),
	]
}

// swift-tools-version: 5.10

import PackageDescription

let package = Package(
	name: "swiftui-navigation-transitions",
	platforms: [
		.iOS(.v13),
		.macCatalyst(.v13),
		.tvOS(.v13),
	],
	products: [
		.library(name: "NavigationTransitions", targets: ["NavigationTransitions"]),
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
		]),

		.target(name: "NavigationTransitions", dependencies: [
			"NavigationTransition",
			"RuntimeAssociation",
			"RuntimeSwizzling",
			.product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
		]),

		.target(name: "RuntimeAssociation"),
		.target(name: "RuntimeSwizzling"),

		.target(name: "TestUtils", dependencies: [
			.product(name: "CustomDump", package: "swift-custom-dump"),
			"NavigationTransitions",
			.product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
		]),
	]
)

// MARK: Dependencies

package.dependencies = [
	.package(url: "https://github.com/siteline/swiftui-introspect", from: "1.0.0"),
	.package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"), // dev
	.package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"), // dev
]

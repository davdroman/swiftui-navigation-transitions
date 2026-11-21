// swift-tools-version: 6.2

import PackageDescription

// swift-custom-dump gets IssueReporting from xctest-dynamic-overlay before Swift 6.4 and from
// swift-issue-reporting from Swift 6.4 on. Both packages declare the same targets, so only the
// one swift-custom-dump uses can be in the graph.
#if compiler(>=6.4)
let issueReporting = (package: "swift-issue-reporting", from: Version(2, 0, 0))
#else
let issueReporting = (package: "xctest-dynamic-overlay", from: Version(1, 0, 0))
#endif

let package = Package(
	name: "swiftui-navigation-transitions",
	platforms: [
		.iOS(.v16),
		.macCatalyst(.v16),
		.tvOS(.v16),
		.visionOS(.v1),
	],
	products: [
		.library(name: "SwiftUINavigationTransitions", targets: ["SwiftUINavigationTransitions"]),
		.library(name: "UIKitNavigationTransitions", targets: ["UIKitNavigationTransitions"]),
	],
	targets: [
		.target(name: "Animation"),
		.testTarget(name: "AnimationTests", dependencies: [
			"Animation",
		]),

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
			.product(name: "IssueReporting", package: issueReporting.package),
		]),

		.target(name: "UIKitNavigationTransitions", dependencies: [
			.product(name: "IssueReporting", package: issueReporting.package),
			"NavigationTransition",
			.product(name: "ObjCRuntimeTools", package: "objc-runtime-tools"),
			.product(name: "Once", package: "swift-once-macro"),
		]),
		.testTarget(name: "UIKitNavigationTransitionsTests", dependencies: [
			"UIKitNavigationTransitions",
		]),

		.target(name: "SwiftUINavigationTransitions", dependencies: [
			"UIKitNavigationTransitions",
			.product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
		]),

		.target(name: "TestUtils", dependencies: [
			.product(name: "CustomDump", package: "swift-custom-dump"),
			.product(name: "IssueReporting", package: issueReporting.package),
			"SwiftUINavigationTransitions",
		]),
	],
)

// MARK: Dependencies

package.dependencies = [
	.package(url: "https://github.com/davdroman/objc-runtime-tools", from: "0.1.0"),
	.package(url: "https://github.com/davdroman/swift-once-macro", from: "1.0.0"),
	.package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"), // dev
	.package(url: "https://github.com/pointfreeco/\(issueReporting.package)", from: issueReporting.from),
	.package(url: "https://github.com/siteline/swiftui-introspect", "26.0.0"..<"28.0.0-beta"),
]

for target in package.targets {
	target.swiftSettings = target.swiftSettings ?? []
	target.swiftSettings? += [
		.enableUpcomingFeature("ExistentialAny"),
		.enableUpcomingFeature("ImmutableWeakCaptures"),
		.enableUpcomingFeature("InferIsolatedConformances"),
		.enableUpcomingFeature("InternalImportsByDefault"),
		.enableUpcomingFeature("MemberImportVisibility"),
		.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
	]
}

// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftui-navigation-transitions",
    platforms: [
        .iOS(.v13),
    ]
)

// MARK: Dependencies

package.dependencies = [
    .package(url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.4"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.6.0"), // dev
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.5.0"), // dev
]

let Introspect: Target.Dependency = .product(
    name: "Introspect",
    package: "SwiftUI-Introspect"
)

let CustomDump: Target.Dependency = .product(
    name: "CustomDump",
    package: "swift-custom-dump"
)

let XCTestDynamicOverlay: Target.Dependency = .product(
    name: "XCTestDynamicOverlay",
    package: "xctest-dynamic-overlay"
)

// MARK: Targets

package.targets += [
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
        Introspect,
    ]),
    .testTarget(name: "NavigationTransitionTests", dependencies: [
        "NavigationTransition",
        "TestUtils",
    ]),

    .target(name: "NavigationTransitions", dependencies: [
        "NavigationTransition",
    ]),

    .target(name: "TestUtils", dependencies: [
        CustomDump,
        "NavigationTransitions",
        XCTestDynamicOverlay,
    ]),
]

// MARK: Product

package.products += [
    .library(name: "NavigationTransitions", targets: ["NavigationTransitions"]),
]

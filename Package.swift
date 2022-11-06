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
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.5.0"),
]

let introspect: Target.Dependency = .product(
    name: "Introspect",
    package: "SwiftUI-Introspect"
)

let xcTestDynamicOverlay: Target.Dependency = .product(
    name: "XCTestDynamicOverlay",
    package: "xctest-dynamic-overlay"
)

// MARK: Targets

package.targets += [
    .target(name: "Animation"),

    .target(name: "Animator", dependencies: [
        xcTestDynamicOverlay,
    ]),
    .testTarget(name: "AnimatorTests", dependencies: [
        "Animator",
    ]),

    .target(name: "AtomicTransition", dependencies: [
        "Animator",
    ]),
    .testTarget(name: "AtomicTransitionTests", dependencies: [
        "AtomicTransition",
    ]),

    .target(name: "NavigationTransition", dependencies: [
        "Animation",
        "AtomicTransition",
        introspect,
    ]),

    .target(name: "NavigationTransitions", dependencies: [
        "NavigationTransition",
    ]),
]

// MARK: Product

package.products += [
    .library(name: "NavigationTransitions", targets: ["NavigationTransitions"]),
]

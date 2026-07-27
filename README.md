# SwiftUINavigationTransitions

[![CI](https://github.com/davdroman/swiftui-navigation-transitions/actions/workflows/ci.yml/badge.svg)](https://github.com/davdroman/swiftui-navigation-transitions/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdavdroman%2Fswiftui-navigation-transitions%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/davdroman/swiftui-navigation-transitions)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdavdroman%2Fswiftui-navigation-transitions%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/davdroman/swiftui-navigation-transitions)
[![](https://img.shields.io/badge/Documentation-gray?logo=googledocs&logoColor=white)](https://swiftpackageindex.com/davdroman/swiftui-navigation-transitions/main/documentation/swiftuinavigationtransitions)

<p align="center">
<img width="320" src="https://user-images.githubusercontent.com/2538074/201549712-4234ca45-bdeb-42c4-9ee9-8d44b346ecdd.gif">
<img width="320" src="https://user-images.githubusercontent.com/2538074/201549897-147e90a0-3773-42ab-94bc-1065fbb7a66b.gif">
<img width="320" src="https://user-images.githubusercontent.com/2538074/201549995-62b86d4a-aa8b-4a6e-9bb4-5ed70cd47d84.gif">
<img width="320" src="https://user-images.githubusercontent.com/2538074/201550282-64ce0f8e-8f99-4fe2-baf8-583e35c0518a.gif">
</p>

**SwiftUINavigationTransitions** is a library that integrates seamlessly with SwiftUI's `NavigationView` and `NavigationStack`, allowing complete customization over **push and pop transitions**!

## Overview

Instead of reinventing the entire navigation stack just to control its transitions, this library ships with a **simple modifier** that can be applied directly to SwiftUI's very own **first-party navigation** components.

### The Basics

#### iOS 13+

```swift
NavigationView {
  // ...
}
.navigationViewStyle(.stack)
.customNavigationTransition(.slide)
```

#### iOS 16+

```swift
NavigationStack {
  // ...
}
.customNavigationTransition(.slide)
```

---

The API is designed to resemble that of built-in SwiftUI Transitions for maximum **familiarity** and **ease of use**.

You can apply **custom animations** just like with standard SwiftUI transitions:

```swift
.customNavigationTransition(
    .fade(.in).animation(.easeInOut(duration: 0.3))
)
```

You can **combine** them:

```swift
.customNavigationTransition(
    .slide.combined(with: .fade(.in))
)
```

And you can **dynamically** choose between transitions based on logic:

```swift
.customNavigationTransition(
    reduceMotion ? .fade(.in).animation(.linear) : .slide(.vertical)
)
```

### Transitions

The library ships with some **standard transitions** out of the box:

- [`default`](Sources/NavigationTransition/Default.swift)
- [`fade(_:)`](Sources/NavigationTransition/Fade.swift)
- [`slide(axis:)`](Sources/NavigationTransition/Slide.swift)

In addition to these, you can create fully [**custom transitions**](https://swiftpackageindex.com/davdroman/swiftui-navigation-transitions/main/documentation/swiftuinavigationtransitions/custom-transitions) in just a few lines of SwiftUI-like code!

```swift
struct Swing: NavigationTransitionProtocol {
    var body: some NavigationTransitionProtocol {
        Slide(axis: .horizontal)
        MirrorPush {
            let angle = 70.0
            let offset = 150.0
            OnInsertion {
                ZPosition(1)
                Rotate(.degrees(-angle))
                Offset(x: offset)
                Opacity()
                Scale(0.5)
            }
            OnRemoval {
                Rotate(.degrees(angle))
                Offset(x: -offset)
            }
        }
    }
}
```

The [**Demo**](Examples/Demo) app showcases some of these transitions in action.

### Interactivity

Choose from three interactivity options: `.disabled`, `.edgePan`, or `.contentPan`:

```swift
.customNavigationTransition(.slide, interactivity: .disabled) // disables back swipes
```

`.contentPan` back-deploys iOS 26 full-screen **pop gestures** all the way to iOS 13:

```swift
.customNavigationTransition(.slide, interactivity: .contentPan) // works on iOS 13-26!
```

This also works while maintaining the **default system transition**:

```swift
.customNavigationTransition(.default, interactivity: .contentPan) // works on iOS 13-26!
```

## Installation

Add the package via Swift Package Manager:

``` swift
dependencies: [
    .package(url: "https://github.com/davdroman/swiftui-navigation-transitions", from: "0.19.0"),
]
```

```swift
.product(name: "SwiftUINavigationTransitions", package: "swiftui-navigation-transitions"),
```

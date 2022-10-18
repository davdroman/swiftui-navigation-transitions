# NavigationTransitions

[![CI](https://github.com/davdroman/swiftui-navigation-transitions/actions/workflows/ci.yml/badge.svg)](https://github.com/davdroman/swiftui-navigation-transitions/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdavdroman%2Fswiftui-navigation-transitions%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/davdroman/swiftui-navigation-transitions)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdavdroman%2Fswiftui-navigation-transitions%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/davdroman/swiftui-navigation-transitions)

<p align="center">
    <img width="320" src="https://user-images.githubusercontent.com/2538074/199754334-7f2f801d-1d9e-4cc4-a7a0-bb22c9835007.gif">
</p>

**NavigationTransitions** is a library that integrates seamlessly with SwiftUI's **Navigation** views, allowing complete customization over **push and pop transitions**!

The library is fully compatible with:

- **`NavigationView`** (iOS 13+)
- **`NavigationStack`** & **`NavigationSplitView`** (iOS 16)

## Overview

As opposed reinventing entire navigation components in order to customize its transitions, `NavigationTransitions` ships as a simple set of 2 modifiers that can be applied directly to SwiftUI's very own first-party navigation components.

### The Basics

#### iOS 13+

```swift
NavigationView {
  // ...
}
.navigationViewStyle(.stack)
.navigationViewStackTransition(.slide)
```

```swift
NavigationView {
  // ...
}
.navigationViewStyle(.columns)
.navigationViewColumnTransition(.slide, forColumns: .all)
```

#### iOS 16

```swift
NavigationStack {
  // ...
}
.navigationStackTransition(.slide)
```

```swift
NavigationSplitView {
  // ...
}
.navigationSplitViewTransition(.slide, forColumns: .all)
```

---

The API is designed to resemble that of built-in SwiftUI Transitions for maximum **familiarity** and **ease of use**.

You can apply **custom animations** just like with standard SwiftUI transitions:

```swift
.navigationViewStackTransition(
    .fade(.in).animation(.easeInOut(duration: 0.3))
)
```

You can **combine** them:

```swift
.navigationViewStackTransition(
    .slide.combined(with: .fade(.in))
)
```

And you can **dynamically** choose between transitions based on logic:

```swift
.navigationViewStackTransition(
    reduceMotion ? .fade(.in).animation(.linear) : .move(.vertically)
)
```

### Transitions

The library ships with some **standard transitions** out of the box:

- [`default`](Sources/NavigationTransition/Default.swift)
- [`fade(_:)`](Sources/NavigationTransition/Fade.swift)
- [`move(axis:)`](Sources/NavigationTransition/Move.swift)
- [`slide`](Sources/NavigationTransition/Slide.swift)

In addition to these, you can create fully **custom transitions** in just a few lines of code with the following:

- [`asymmetric(push:pop:)`](Sources/NavigationTransition/Asymmetric.swift)
- [`combined(with:)`](Sources/NavigationTransition/Combined.swift)
- [`custom(withAnimator:)`](Sources/NavigationTransition/Custom.swift)
- [`custom(withTransientViews:)`](Sources/NavigationTransition/Custom.swift)

The [**Demo**](Demo) app showcases some of these transitions in action.

### Interactivity

A sweet additional feature is the ability to override the behavior of the **pop gesture** on the navigation view:

```swift
.navigationViewStackTransition(.slide, interactivity: .pan) // full-pan screen gestures!
```

This even works to override its behavior while maintaining the **default system transition** in iOS:

```swift
.navigationViewStackTransition(.default, interactivity: .pan) // ✨
```

## Documentation

The repository contains [**documentation**](Documentation) covering how to set up your own custom transitions.

## Community

Feel free to **post questions**, **ideas**, or any **cool transitions** you build in the [**Discussions**](https://github.com/davdroman/swiftui-navigation-transitions/discussions) section!

I sincerely hope you enjoy using this library as much as I enjoyed building it ❤️

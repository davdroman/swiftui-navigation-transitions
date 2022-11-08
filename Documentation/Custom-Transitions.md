# Custom Transitions

This document will guide you through the entire technical explanation on how to build custom navigation transitions.

As a first time reader, it is highly recommended that you read **Core Concepts** first before jumping onto one of the implementation sections, in order to understand the base abstractions you'll be working with.

- [**Core Concepts**](#Core-Concepts)
  - [**`NavigationTransition`**](#NavigationTransition)
  - [**`AtomicTransition`**](#AtomicTransition)
  
- [**Implementation**](#Implementation)
  - [**Basic**](#Basic)
  - [**Recommended**](#Recommended)
  - [**UIKit**](#UIKit)

## Core Concepts

### `NavigationTransition`

The main construct the library leverages is called `AnyNavigationTransition`. You may have seen some instances of this type in the README's code samples (e.g. `.slide`).

 `AnyNavigationTransition` instances describe both `push` and `pop` transitions for both *origin* and *destination* views.

If we dive into the implementation of `AnyNavigationTransition.slide`, we'll find this:

```swift
extension AnyNavigationTransition {
    /// [...]
    public static func slide(axis: Axis) -> Self {
        .init(Slide(axis: axis))
    }
}
```

As you can see, there's not much going on here. The reason is that `AnyNavigationTransition` is actually just a type erasing wrapper around the real meat and potatoes: the protocol `NavigationTransition`.

Let's take a look at what (capital "S") `Slide` is:

```swift
public struct Slide: NavigationTransition {
    private let axis: Axis

    public init(axis: Axis) {
        self.axis = axis
    }

    public var body: some NavigationTransition {
        switch axis {
        case .horizontal:
            MirrorPush {
                OnInsertion {
                    Move(edge: .trailing)
                }
                OnRemoval {
                    Move(edge: .leading)
                }
            }
        case .vertical:
            MirrorPush {
                OnInsertion {
                    Move(edge: .bottom)
                }
                OnRemoval {
                    Move(edge: .top)
                }
            }
        }
    }
}
```

This is more like it!

As you can see, `NavigationTransition` leverages result builder syntax to define "what" transitions do, not "how" they do it. Notice how the entire transition is implemented concisely, yet there's **no explicit `UIView` animation** code to be seen anywhere at this point. I'd like to direct your attention instead to what's actually describing the transition at its core: `Move(edge: ...)`.

If you've used SwiftUI's `transition` modifier before, it's easy to draw a comparison to `AnyTransition.move(edge:)`. And in fact, whilst the API is slightly different, the intent behind it is the same indeed! `Move` is a type that conforms to the building block of the library: `AtomicTransition`.

### `AtomicTransition`

`AtomicTransition` is a SwiftUI `AnyTransition`-inspired type which acts very much in the same manner. It can describe a specific set of view changes on an individual ("atomic") basis, for both **insertion** and **removal** of said view. 

Contrary to `NavigationTransition` and as the name indicates, `AtomicTransition` applies to only a **single view** out of the two, and is **agnostic** as to the **intent** (push or pop) of its **parent** `NavigationTransition`.

If we dive even deeper into `Move`, this is what we find:

```swift
public struct Move: AtomicTransition {
    private let edge: Edge

    public init(edge: Edge) {
        self.edge = edge
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        switch (edge, operation) {
        case (.top, .insertion):
            view.initial.translation.dy = -container.frame.height
            view.animation.translation.dy = 0

        case (.leading, .insertion):
            view.initial.translation.dx = -container.frame.width
            view.animation.translation.dx = 0

        case (.trailing, .insertion):
            view.initial.translation.dx = container.frame.width
            view.animation.translation.dx = 0

        case (.bottom, .insertion):
            view.initial.translation.dy = container.frame.height
            view.animation.translation.dy = 0

        case (.top, .removal):
            view.animation.translation.dy = -container.frame.height
            view.completion.translation.dy = 0

        case (.leading, .removal):
            view.animation.translation.dx = -container.frame.width
            view.completion.translation.dx = 0

        case (.trailing, .removal):
            view.animation.translation.dx = container.frame.width
            view.completion.translation.dx = 0

        case (.bottom, .removal):
            view.animation.translation.dy = container.frame.height
            view.completion.translation.dy = 0
        }
    }
}
```

Now we're talking! There's some basic math and value assignments happening, but nothing resembling a typical `UIView` animation block even at this point. Although there are some references to `animation` and `completion`, which are very familiar concepts in UIKit world.

We'll be covering what these are in just a moment, but as a closing thought before we jump onto the nitty gritty of the implementation, take a moment to acknowledge the inherent **layered approach** this library uses to describe transitions. This design philosophy is the basis for building great, easily maintainable, non-glitchy transitions down the road.

## Implementation

### Basic

#### `AnyNavigationTransition.combined(with:)`

You can create a custom `AnyNavigationTransition` by combining two existing transitions:

```swift
.slide.combined(with: .fade(.in))
```

It is rarely the case where you'd want to combine `AnyNavigationTransition`s in this manner due to their nature as high level abstractions. In fact, most of the time they won't combine very well at all, and will produce glitchy or weird effects. This is because two or more fully-fledged transitions tend to override the same view properties with different values, producing unexpected outcomes.

Instead, most combinations should happen at lowers level, in `NavigationTransition` and `AtomicTransition` conformances.

Regardless, it's still allowed for cases like `slide` + `fade(in:)`, which affect completely different properties of the view. Separatedly, `slide` only moves the views horizontally, and `.fade(.in)` fades views in. When combined, both occur at the same time without interfering with each other.

### Recommended

Let's delve into how `AtomicTransition` actually works, by taking another look at the implementation of `Move`:

```swift
public struct Move: AtomicTransition {
    private let edge: Edge

    public init(edge: Edge) {
        self.edge = edge
    }

    public func transition(_ view: TransientView, for operation: TransitionOperation, in container: Container) {
        switch (edge, operation) {
        case (.top, .insertion):
            view.initial.translation.dy = -container.frame.height
            view.animation.translation.dy = 0

        case (.leading, .insertion):
            view.initial.translation.dx = -container.frame.width
            view.animation.translation.dx = 0

        case (.trailing, .insertion):
            view.initial.translation.dx = container.frame.width
            view.animation.translation.dx = 0

        case (.bottom, .insertion):
            view.initial.translation.dy = container.frame.height
            view.animation.translation.dy = 0

        case (.top, .removal):
            view.animation.translation.dy = -container.frame.height
            view.completion.translation.dy = 0

        case (.leading, .removal):
            view.animation.translation.dx = -container.frame.width
            view.completion.translation.dx = 0

        case (.trailing, .removal):
            view.animation.translation.dx = container.frame.width
            view.completion.translation.dx = 0

        case (.bottom, .removal):
            view.animation.translation.dy = container.frame.height
            view.completion.translation.dy = 0
        }
    }
}
```

All types conforming to `AtomicTransition` must implement what's known as a "transition handler". This transition handler hands over several things for us to work with:

- A `TransientView` instance, which is actually an abstraction over the `UIView` being inserted or removed under the hood by UIKit (and thus SwiftUI) as part of a push or a pop. The reason it exists is because it helps abstract away all of the UIKit animation logic and instead allows you to focus on assigning the desired values for each stage of the transition (`initial`, `animation`, and `completion`). It also helps the transition engine with merging transition states under the hood, making sure two atomic transitions affecting the same property don't accidentally cause glitchy UI behavior.
- `Operation` defines whether the operation being performed is an `insertion` or a `removal` of the view, which should help you differentiate and set up your property values accordingly.
- `Container` is a direct typealias to `UIView`, and it represents the container in which the transition is ocurring. There's no need to add `TransientView` to this container as the library does this for you. Even better, there's no way to even accidentally do it because `TransientView` is not a `UIView` subclass.

---

Next up, let's explore two ways of conforming to `NavigationTransition`.

The simplest (and most recommended) way is by declaring our atomic transitions (if needed), and composing them via `var body: some NavigationTransition { ... }` like we saw [previously with `Slide`](#NavigationTransition).

Check out the [documentation](https://swiftpackageindex.com/davdroman/swiftui-navigation-transitions/0.2.0/documentation/navigationtransitions/navigationtransition) to learn about the different `NavigationTransition` types and how they compose.

The Demo project in the repo is also a great source of learning about different types of custom transitions and the way to implement them.

---

Finally, let's explore an alternative option for those who'd like to reach for a more wholistic API. `NavigationTransition` declares a `transition` function that can be implemented instead of `body`:

```swift
func transition(from fromView: TransientView, to toView: TransientView, for operation: TransitionOperation, in container: Container)
```

Whilst `body` helps composing other transitions, this transition handler helps us define a completely custom transition without reaching down to atomic transitions as building blocks. You can roll your own logic as you would with `AtomicTransition` earlier, but with full context of the transition:

- `fromView` and `toView` are `TransientView`s corresponding to the *origin* and *destination* views involved in the transition. They work just like with `AtomicTransition`.
- `Operation` defines whether the operation being performed is a `push` or a `pop`. The concept of insertions or removals is entirely irrelevant to this function, since you can directly modify the property values for the views without needing atomic transitions.
- `Container` is the container view of type `UIView` where `fromView` and `toView` are added during the transition. There's no need to add either view to this container as the library does this for you. Even better, there's no way to even accidentally do it because `TransientView` is not a `UIView` subclass.

This approach is a less cumbersome one to take in case you're working on an app that only requires one custom navigation transition. However, if you're working on an app that features multiple custom transitions, it is recommended that you model your navigation transitions via atomic transitions as described earlier. In the long term, this will be beneficial to your development and iteration speed, by promoting code reusability amongst your team.

### UIKit

We're now exploring the edges of the API surface of this library. Anything past this point entails a level of granularity that should be rarely needed in any team, unless:

- You intend to migrate one of your existing [`UIViewControllerAnimatedTransitioning`](https://developer.apple.com/documentation/uikit/uiviewcontrolleranimatedtransitioning) implementations over to SwiftUI.
- You're well versed in *Custom UINavigationController Transitions* and are willing to dive straight into raw UIKit territory, including view snapshotting, hierarchy set-up, lifecycle management, and animator configuration. Even then, I highly encourage you to consider using one of the formerly discussed abstractions in order to accomplish the desired effect instead.

Before we get started, I'd like to ask that if you're reaching for these abstractions because there's something missing in the previously discussed customization mechanisms that you believe should be there to build your transition the way you need, **please** [**open an issue**](https://github.com/davdroman/swiftui-navigation-transitions/issues/new) in order to let me know, so I can close the capability gap between abstractions and make everyone's development experience richer.

Let's delve into the final customization entry point, which as mentioned interacts with UIKit abstractions directly.

The entire concept of advanced custom transitions revolves around an `Animator` object. This `Animator` is a protocol which exposes a subset of functions in the UIKit protocol [`UIViewImplicitlyAnimating`](https://developer.apple.com/documentation/uikit/uiviewimplicitlyanimating).

The interface looks as follows:

```swift
@objc public protocol Animator {
    func addAnimations(_ animation: @escaping () -> Void)
    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void)
}
```

In order to adopt this, you must declare a type conforming to `PrimitiveNavigationTransition`, and implement its transition handler:

```swift
struct MyTransition: PrimitiveNavigationTransition {
    func transition(with animator: Animator, for operation: TransitionOperation, in context: Context) {
        // ...
    }
}
```

- `Animator` is used to setup animations and completion logic.
- `Operation` describes the `push` or `pop` operation being performed.
- `Context` ([`UIViewControllerContextTransitioning`](https://developer.apple.com/documentation/uikit/uiviewcontrollercontexttransitioning)) gives you access to the views being animated and more.

This function can be thought of as the equivalent of [`UIViewControllerAnimatedTransitioning.animateTransition(using:)`](https://developer.apple.com/documentation/uikit/uiviewcontrolleranimatedtransitioning/1622061-animatetransition), except it also handles interactive pops automatically for you (as long as you use the provided animator).

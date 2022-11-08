# Custom Transitions

This document will guide you through the entire technical explanation on how to build custom navigation transitions.

As a first time reader, it is highly recommended that you read **Core Concepts** first before jumping onto one of the implementation sections, in order to understand the base abstractions you'll be working with.

- [**Core Concepts**](#Core-Concepts)
  - [**`NavigationTransition`**](#NavigationTransition)
  - [**`AtomicTransition`**](#AtomicTransition)
  
- [**Implementation**](#Implementation)

  - [**Basic**](#Basic)
  - [**Intermediate**](#Intermediate)
  - [**Advanced**](#Advanced)

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
            OnPush {
                OnInsertion {
                    Move(edge: .trailing)
                }
                OnRemoval {
                    Move(edge: .leading)
                }
            }
            OnPop {
                OnInsertion {
                    Move(edge: .leading)
                }
                OnRemoval {
                    Move(edge: .trailing)
                }
            }
        case .vertical:
            OnPush {
                OnInsertion {
                    Move(edge: .bottom)
                }
                OnRemoval {
                    Move(edge: .top)
                }
            }
            OnPop {
                OnInsertion {
                    Move(edge: .top)
                }
                OnRemoval {
                    Move(edge: .bottom)
                }
            }
        }
    }
}
```

This is more like it!

As you can see, `NavigationTransition` leverages result builder syntax to define "what" transitions do, not "how" they do it. Notice how the entire transition is implemented concisely, yet there's **no explicit `UIView` animation** code to be seen anywhere at this point. I'd like to direct your attention instead to what's actually describing the transition at its core: `Move(edge: ...)`.

If you've used the SwiftUI `transition` modifier before, it's easy to draw a comparison to `AnyTransition.move(edge:)`. And in fact, whilst the API is slightly different, the intent behind it is the same indeed! `Move` is a type that conforms to the building block of the library: `AtomicTransition`.

### `AtomicTransition`

`AtomicTransition` is a SwiftUI `AnyTransition`-inspired type which acts very much in the same manner. It can describe a specific set of view changes on an individual ("atomic") basis, for both **insertion** and **removal** of said view. 

Contrary to `NavigationTransition` and as the name indicates, `AtomicTransition` applies to only a **single view** out of the two, and is **agnostic** as to the **intent** (push or pop) of its **parent** `NavigationTransition`.

If we dive even deeper into `Move`, this is what we find:

```swift
extension AtomicTransition {
    /// A transition entering from `edge` on insertion, and exiting towards `edge` on removal.
    public static func move(edge: Edge) -> Self {
        .custom { view, operation, container in
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
}
```

Now we're talking! There's some basic math and value assignments happening, but nothing resembling a typical `UIView` animation block just yet. Although there are some references to `animation` and `completion`, which are very familiar concepts in UIKit world.

We'll be covering what these are in just a moment, but as a closing thought before we jump onto the nitty gritty of the implementation, take a moment to acknowledge the inherent **layered approach** this library uses to describe transitions. This design philosophy is the basis for building great, non-glitchy transitions down the line.

## Implementation

### Basic

There are 2 main entry points for building a `NavigationTransition`:

#### `NavigationTransition.combined(with:)`

You can create a custom `NavigationTransition` by combining two existing transitions:

```swift
.slide.combined(with: .fade(.in))
```

It is rarely the case where you'd want to combine `NavigationTransition`s in this manner due to their nature as high level abstractions. In fact, most of the time they won't combine very well at all, and will produce glitchy or weird effects. This is because two or more fully-fledged transitions tend to override the same view properties with different values, producing unexpected outcomes.

Instead, most combinations should happen with the lower level abstraction `AtomicTransition`.

Regardless, it's still allowed for cases like `slide` + `fade(in:)`, which affect completely different properties of the view. Separatedly, `slide` only moves the views horizontally, and `.fade(.in)` fades views in. When combined, both occur at the same time without interfering with each other.

#### `NavigationTransition.asymmetric(push:pop:)`

```swift
.asymmetric(push: .fade(.cross), pop: .slide)
```

This second, more interesting entry point is one reminiscent of SwiftUI's asymmetric transition API. As the name suggest, this transition splits the `push` transition from the `pop` transition, to make them as different as you wish.

You can use this method with a pair of `NavigationTransition` values or, more importantly, a pair of `AtomicTransition` values. Most transitions will utilize the latter due to its superior granularity.

---

There are 2 main entry points for building an `AtomicTransition`:

#### `AtomicTransition.combined(with:)`

```swift
.move(edge: .trailing).combined(with: .scale(0.5))
```

The API is remarkably similar to `AnyTransition` on purpose, and acts on a single view in the same way you'd expect the first-party API to behave.

It's important to understand the **nuance** this entails: regardless of whether its parent transition is `push` or `pop`, this transition will insert the incoming view from the trailing edge and scale it from an initial value of 0.5 to a final value of 1. In the same manner, the outgoing view will be removed by moving away towards the same trailing edge and scaling down from 1 to 0.5. In order to actually apply a different edge movement for insertion vs removal you'll need to use the `.asymmetric` transition described below.

#### `AtomicTransition.asymmetric(insertion:removal:)`

```swift
.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .scale(0.5)),
    removal: .move(edge: .leading).combined(with: .scale(0.5))
)
```

Just like `AnyTransition.asymmetric`, this transition uses a different transition for insertion vs removal, and acts as a cornerstone for custom transitions along with its `NavigationTransition.asymmetric(push:pop:)` counterpart.

Now that you understand the 4 basic customization entry points the library has to offer, you should be able to refer back to the earlier [**example**](#NavigationTransition) and understand a bit more about how the entire implementation works.

### Intermediate

In addition to the basic entry points to customization described in the previous section, let's delve even deeper into how primitive transitions actually work. By "primitive transitions" I'm referring to standalone transitions which are not the result of composing other transitions together, but which rather define what the transition actually does to a view in animation terms.

The primitive transitions which currently ship with this library are:

- `AtomicTransition.identity`
- `AtomicTransition.move(edge:)`
- `AtomicTransition.offset(x:y:)`
- `AtomicTransition.opacity(_:)`
- `AtomicTransition.rotate(_:)`
- `AtomicTransition.scale(_:)`
- `AtomicTransition.zPosition(_:)`

Let's take another look at the implementation of `.move(edge:)`:

```swift
extension AtomicTransition {
    /// A transition entering from `edge` on insertion, and exiting towards `edge` on removal.
    public static func move(edge: Edge) -> Self {
        .custom { view, operation, container in
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
}
```

Here we find neither `.asymmetric` nor `.combined` are used for this primitive transition. Instead, we find a `.custom` initializer with the following signature:

```swift
// AtomicTransition.swift
public static func custom(withTransientView handler: @escaping TransientViewHandler) -> Self
```

... where `TransientViewHandler` is a typealias for `(TransientView, Operation, Container) -> Void`.

`TransientView` is actually an abstraction over the `UIView` which is being inserted or removed under the hood by UIKit (and thus SwiftUI) as part of a push or a pop. The reason this abstraction exists is because it helps abstract away all of the UIKit animation logic and instead allows one to focus on assigning the desired values for each stage of the transition (`initial`, `animation`, and `completion`). It also helps the transition engine with merging transition states under the hood, making sure two primitive transitions affecting the same property don't accidentally cause glitchy UI behavior.

Alongside `TransientView`, `Operation` defines whether the operation being performed is an `insertion` or a `removal` of the view, which should help you differentiate and set up your property values accordingly.

Finally, container is a direct typealias to `UIView`, and it represents the container in which the transition is ocurring. There's no need to add `TransientView` to this container as the library does this for you. Even better, there's no way to even accidentally do it because `TransientView` is not a `UIView` subclass.

---

Whilst composing `AtomicTransition`s is the recommended way of building up to a `NavigationTransition`, there is actually an **alternative** option for those who'd like to reach for a more wholistic API:

```swift
// NavigationTransition.swift
public static func custom(withTransientViews handler: @escaping TransientViewsHandler) -> Self
```

... where `TransientViewsHandler` is a typealias for `(FromView, ToView, Operation, Container) -> Void`.

`FromView` and `ToView` are typealiases for the `TransientView`s corresponding to the origin and destination views involved in the transition.

Alongside them, `Operation` defines whether the operation being performed is a `push` or a `pop`. The concept of insertions or removals is entirely removed from this abstraction, since you can directly modify the property values for the views without needing atomic transitions.

This approach is often a simple one to take in case you're working on an app that only requires one custom navigation transition. However, if you're working on an app that features multiple custom transitions, it is recommended that you model your navigation transitions via atomic transitions as described earlier. In the long term, this will be beneficial to your development and iteration speed, by promoting code reusability amongst your team.

### Advanced

We're now exploring the edges of the API surface of this library. Anything past this point entails a level of granularity that should be rarely needed in any team, unless:

- You intend to migrate one of your existing [`UIViewControllerAnimatedTransitioning`](https://developer.apple.com/documentation/uikit/uiviewcontrolleranimatedtransitioning) implementations over to SwiftUI.
- You're well versed in *Custom UINavigationController Transitions* and are willing to dive straight into raw UIKit territory, including view snapshotting, hierarchy set-up, lifecycle management, and animator configuration. Even then, I highly encourage you to consider using one of the formerly discussed abstractions in order to accomplish the desired effect instead.

Before we get started, I'd like to ask that if you're reaching for these abstractions because there's something missing in the previously discussed customization mechanisms that you believe should be there to build your transition the way you need, **please** [**open an issue**](https://github.com/davdroman/swiftui-navigation-transitions/issues/new) in order to let me know, so I can close the capability gap between abstractions and make everyone's development experience richer.

Let's delve into the two final customization entry points, which as mentioned interact with UIKit abstractions directly.

The entire concept of advanced custom transitions revolves around an `Animator` object. This `Animator` is a protocol which exposes a subset of functions in the UIKit protocol [`UIViewImplicitlyAnimating`](https://developer.apple.com/documentation/uikit/uiviewimplicitlyanimating).

The interface looks as follows:

```swift
@objc public protocol Animator {
    func addAnimations(_ animation: @escaping () -> Void)
    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void)
}
```

The `AtomicTransition` API for utilising this mechanism is:

```swift
// AtomicTransition.swift
public static func custom(withAnimator handler: @escaping AnimatorHandler) -> Self
```

... where `AnimatorHandler` is a typealias for `(Animator, UIView, Operation, Context) -> Void`.

In this case, the `Animator` is utilized to setup animations and completion logic for the inserted or removed `UIView` with access to a `Context` (typealias for [`UIViewControllerContextTransitioning`](https://developer.apple.com/documentation/uikit/uiviewcontrollercontexttransitioning)).

---

The same principle applies to `NavigationTransition` as well:

```swift
public static func custom(withAnimator handler: @escaping AnimatorHandler) -> Self
```

... where `AnimatorHandler` is a typealias for `(Animator, Operation, Context) -> Void`.

In this case, the `Animator` is utilized to setup animations and completion logic for the pushed or popped views which you must extract from `Context` (typealias for [`UIViewControllerContextTransitioning`](https://developer.apple.com/documentation/uikit/uiviewcontrollercontexttransitioning)).

@_implementationOnly import Introspect
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
        self.modifier(
            NavigationTransitionModifier(
                transition: transition,
                interactivity: interactivity
            )
        )
    }
}

struct NavigationTransitionModifier: ViewModifier {
    let transition: AnyNavigationTransition
    let interactivity: AnyNavigationTransition.Interactivity

    func body(content: Content) -> some View {
        content.inject(
            UIKitIntrospectionViewController { spy -> UINavigationController? in
                guard spy.parent != nil else {
                    return nil // don't evaluate view until it's on screen
                }
                if let controller = Introspect.previousSibling(ofType: UINavigationController.self, from: spy) {
                    return controller
                } else if let controller = spy.navigationController {
                    return controller
                } else {
                    runtimeWarn(
                        """
                        Modifier "navigationTransition" was applied to a view other than NavigationStack OR NavigationView with .navigationViewStyle(.stack). This has no effect.

                        You could also be attempting to apply the modifier to NavigationSplitView OR NavigationView with .navigationViewStyle(.columns). This also has no effect.

                        Please make sure you're applying the modifier correctly:

                            NavigationStack {
                                ...
                            }
                            .navigationTransition(...)

                            OR

                            NavigationStack {
                                ...
                            }
                            .navigationViewStyle(.stack)
                            .navigationTransition(...)
                        """
                    )
                    return nil
                }
            }
            customize: { (controller: UINavigationController) in
                controller.setNavigationTransition(transition, interactivity: interactivity)
            }
        )
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

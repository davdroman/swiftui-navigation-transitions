@_implementationOnly import Introspect
import SwiftUI

// MARK: iOS 16

@available(iOS, introduced: 16)
public struct NavigationSplitViewColumns: OptionSet {
    public static let sidebar = Self(rawValue: 1)
    public static let content = Self(rawValue: 1 << 1)
    public static let detail = Self(rawValue: 1 << 2)

    public static let compact = Self(rawValue: 1 << 3)

    public static let all: Self = [compact, sidebar, content, detail]

    public let rawValue: Int8

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}

@available(iOS, introduced: 16)
extension UISplitViewControllerColumns {
    init(_ columns: NavigationSplitViewColumns) {
        var _columns: Self = []
        if columns.contains(.sidebar) {
            _columns.insert(.primary)
        }
        if columns.contains(.content) {
            _columns.insert(.supplementary)
        }
        if columns.contains(.detail) {
            _columns.insert(.secondary)
        }
        if columns.contains(.compact) {
            _columns.insert(.compact)
        }
        self = _columns
    }
}

extension View {
    @available(iOS, introduced: 16)
    @ViewBuilder
    public func navigationSplitViewTransition(
        _ transition: AnyNavigationTransition,
        forColumns columns: NavigationSplitViewColumns,
        interactivity: NavigationTransitionInteractivity = .default
    ) -> some View {
        self.modifier(
            NavigationSplitOrStackTransitionModifier(
                transition: transition,
                target: .navigationSplitView(columns),
                interactivity: interactivity
            )
        )
    }

    @available(iOS, introduced: 16)
    @ViewBuilder
    public func navigationStackTransition(
        _ transition: AnyNavigationTransition,
        interactivity: NavigationTransitionInteractivity = .default
    ) -> some View {
        self.modifier(
            NavigationSplitOrStackTransitionModifier(
                transition: transition,
                target: .navigationStack,
                interactivity: interactivity
            )
        )
    }
}

@available(iOS, introduced: 16)
struct NavigationSplitOrStackTransitionModifier: ViewModifier {
    enum Target {
        case navigationSplitView(NavigationSplitViewColumns)
        case navigationStack
    }

    let transition: AnyNavigationTransition
    let target: Target
    let interactivity: NavigationTransitionInteractivity

    func body(content: Content) -> some View {
        switch target {
        case .navigationSplitView(let columns):
            content.inject(
                UIKitIntrospectionViewController { spy -> UISplitViewController? in
                    if let controller = Introspect.previousSibling(ofType: UISplitViewController.self, from: spy) {
                        return controller
                    } else {
                        runtimeWarn(
                            """
                            Modifier "navigationSplitViewTransition" was applied to a view other than NavigationSplitView. This has no effect.

                            Please make sure you're applying the modifier correctly:

                                NavigationSplitView {
                                    ...
                                }
                                .navigationSplitViewTransition(...)

                            Otherwise, if you're using a NavigationStack, please apply the corresponding modifier "navigationStackTransition" instead.
                            """
                        )
                        return nil
                    }
                }
                customize: { (controller: UISplitViewController) in
                    controller.setNavigationTransition(transition, forColumns: .init(columns), interactivity: interactivity)
                }
            )

        case .navigationStack:
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
                            Modifier "navigationStackTransition" was applied to a view other than NavigationStack. This has no effect.

                            Please make sure you're applying the modifier correctly:

                                NavigationStack {
                                    ...
                                }
                                .navigationStackTransition(...)

                            Otherwise, if you're using a NavigationSplitView, please apply the corresponding modifier "navigationSplitViewTransition" instead.
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
}

// MARK: - Pre-iOS 16

@available(iOS, introduced: 13, deprecated: 16, message:
    """
    Use `NavigationSplitView` and `.navigationSplitViewTransition` with `NavigationSplitViewColumns` instead.
    """
)
public struct NavigationViewColumns: OptionSet {
    public static let sidebar = Self(rawValue: 1)
    public static let detail = Self(rawValue: 1 << 1)

    public static let all: Self = [sidebar, detail]

    public let rawValue: Int8

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}

extension UISplitViewControllerColumns {
    init(_ columns: NavigationViewColumns) {
        var _columns: Self = []
        if columns.contains(.sidebar) {
            _columns.insert(.primary)
        }
        if columns.contains(.detail) {
            _columns.insert(.secondary)
        }
        self = _columns
    }
}

extension View {
    @available(iOS, introduced: 13, deprecated: 16, renamed: "navigationSplitViewTransition", message:
        """
        Use `NavigationSplitView` and `.navigationSplitViewTransition` instead.
        """
    )
    @ViewBuilder
    public func navigationViewColumnTransition(
        _ transition: AnyNavigationTransition,
        forColumns columns: NavigationViewColumns,
        interactivity: NavigationTransitionInteractivity = .default
    ) -> some View {
        self.modifier(
            NavigationViewTransitionModifier(
                transition: transition,
                style: .columns(columns),
                interactivity: interactivity
            )
        )
    }

    @available(iOS, introduced: 13, deprecated: 16, renamed: "navigationStackTransition", message:
        """
        Use `NavigationStack` and `.navigationStackTransition` instead.
        """
    )
    @ViewBuilder
    public func navigationViewStackTransition(
        _ transition: AnyNavigationTransition,
        interactivity: NavigationTransitionInteractivity = .default
    ) -> some View {
        self.modifier(
            NavigationViewTransitionModifier(
                transition: transition,
                style: .stack,
                interactivity: interactivity
            )
        )
    }
}

struct NavigationViewTransitionModifier: ViewModifier {
    enum Style {
        case columns(NavigationViewColumns)
        case stack
    }

    let transition: AnyNavigationTransition
    let style: Style
    let interactivity: NavigationTransitionInteractivity

    func body(content: Content) -> some View {
        switch style {
        case .columns(let columns):
            content.inject(
                UIKitIntrospectionViewController { spy -> UISplitViewController? in
                    if let controller = Introspect.previousSibling(ofType: UISplitViewController.self, from: spy) {
                        return controller
                    } else {
                        runtimeWarn(
                            """
                            Modifier "navigationViewColumnTransition" was applied to a view other than NavigationView with .navigationViewStyle(.columns). This has no effect.

                            Please make sure you're applying the modifier correctly:

                                NavigationView {
                                    ...
                                }
                                .navigationStyle(.columns)
                                .navigationViewTransition(...)

                            Otherwise, if you're using a NavigationView with .navigationViewStyle(.stack), please apply the corresponding modifier "navigationViewStackTransition" instead.
                            """
                        )
                        return nil
                    }
                }
                customize: { (controller: UISplitViewController) in
                    controller.setNavigationTransition(transition, forColumns: .init(columns), interactivity: interactivity)
                }
            )

        case .stack:
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
                            Modifier "navigationViewStackTransition" was applied to a view other than NavigationView with .navigationViewStyle(.stack). This has no effect.

                            Please make sure you're applying the modifier correctly:

                                NavigationStack {
                                    ...
                                }
                                .navigationViewStyle(.stack)
                                .navigationStackTransition(...)

                            Otherwise, if you're using a NavigationView with .navigationViewStyle(.columns), please apply the corresponding modifier "navigationViewColumnTransition" instead.
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
}

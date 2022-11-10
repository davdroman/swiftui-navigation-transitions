@_spi(package) import NavigationTransition
import UIKit

extension AnyNavigationTransition {
    public enum Interactivity {
        case disabled
        case edgePan
        case pan

        @inlinable
        public static var `default`: Self {
            .edgePan
        }
    }
}

public struct UISplitViewControllerColumns: OptionSet {
    public static let primary = Self(rawValue: 1)
    public static let supplementary = Self(rawValue: 1 << 1)
    public static let secondary = Self(rawValue: 1 << 2)

    public static let compact = Self(rawValue: 1 << 3)

    public static let all: Self = [compact, primary, supplementary, secondary]

    public let rawValue: Int8

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}

extension UISplitViewController {
    public func setNavigationTransition(
        _ transition: AnyNavigationTransition,
        forColumns columns: UISplitViewControllerColumns,
        interactivity: AnyNavigationTransition.Interactivity = .default
    ) {
        if columns.contains(.compact), let compact = compactViewController as? UINavigationController {
            compact.setNavigationTransition(transition, interactivity: interactivity)
        }
        if columns.contains(.primary), let primary = primaryViewController as? UINavigationController {
            primary.setNavigationTransition(transition, interactivity: interactivity)
        }
        if columns.contains(.supplementary), let supplementary = supplementaryViewController as? UINavigationController {
            supplementary.setNavigationTransition(transition, interactivity: interactivity)
        }
        if columns.contains(.secondary), let secondary = secondaryViewController as? UINavigationController {
            secondary.setNavigationTransition(transition, interactivity: interactivity)
        }
    }
}

extension UISplitViewController {
    var compactViewController: UIViewController? {
        if #available(iOS 14, tvOS 14, *) {
            return viewController(for: .compact)
        } else {
            if isCollapsed {
                return viewControllers.first
            } else {
                return nil
            }
        }
    }

    var primaryViewController: UIViewController? {
        if #available(iOS 14, tvOS 14, *) {
            return viewController(for: .primary)
        } else {
            if !isCollapsed {
                return viewControllers.first
            } else {
                return nil
            }
        }
    }

    var supplementaryViewController: UIViewController? {
        if #available(iOS 14, tvOS 14, *) {
            return viewController(for: .supplementary)
        } else {
            if !isCollapsed {
                if viewControllers.count >= 3 {
                    return viewControllers[safe: 1]
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }

    var secondaryViewController: UIViewController? {
        if #available(iOS 14, tvOS 14, *) {
            return viewController(for: .secondary)
        } else {
            if !isCollapsed {
                if viewControllers.count >= 3 {
                    return viewControllers[safe: 2]
                } else {
                    return viewControllers[safe: 1]
                }
            } else {
                return nil
            }
        }
    }
}

extension RandomAccessCollection where Index == Int {
    subscript(safe index: Index) -> Element? {
        self.dropFirst(index).first
    }
}

extension UINavigationController {
    private static var defaultDelegateKey = "defaultDelegate"
    private static var customDelegateKey = "customDelegate"

    private var defaultDelegate: UINavigationControllerDelegate! {
        get { objc_getAssociatedObject(self, &Self.defaultDelegateKey) as? UINavigationControllerDelegate }
        set { objc_setAssociatedObject(self, &Self.defaultDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var customDelegate: NavigationTransitionDelegate! {
        get {
            objc_getAssociatedObject(self, &Self.customDelegateKey) as? NavigationTransitionDelegate
        }
        set {
            objc_setAssociatedObject(self, &Self.customDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = newValue
        }
    }

    public func setNavigationTransition(
        _ transition: AnyNavigationTransition,
        interactivity: AnyNavigationTransition.Interactivity = .default
    ) {
        if defaultDelegate == nil {
            defaultDelegate = delegate
        }

        if transition.type == Default.self {
            delegate = defaultDelegate
        } else {
            customDelegate = NavigationTransitionDelegate(transition: transition, baseDelegate: defaultDelegate)
        }

        #if !os(tvOS)
        if defaultPanRecognizer == nil {
            defaultPanRecognizer = UIPanGestureRecognizer()
            defaultPanRecognizer.targets = defaultEdgePanRecognizer?.targets // https://stackoverflow.com/a/60526328/1922543
            defaultPanRecognizer.strongDelegate = NavigationGestureRecognizerDelegate(controller: self)
            view.addGestureRecognizer(defaultPanRecognizer)
        }

        if edgePanRecognizer == nil {
            edgePanRecognizer = UIScreenEdgePanGestureRecognizer()
            edgePanRecognizer.edges = .left
            edgePanRecognizer.addTarget(self, action: #selector(handleInteraction))
            edgePanRecognizer.strongDelegate = NavigationGestureRecognizerDelegate(controller: self)
            view.addGestureRecognizer(edgePanRecognizer)
        }

        if panRecognizer == nil {
            panRecognizer = UIPanGestureRecognizer()
            panRecognizer.addTarget(self, action: #selector(handleInteraction))
            panRecognizer.strongDelegate = NavigationGestureRecognizerDelegate(controller: self)
            view.addGestureRecognizer(panRecognizer)
        }

        if transition.type == Default.self {
            switch interactivity {
            case .disabled:
                exclusivelyEnableGestureRecognizer(.none)
            case .edgePan:
                exclusivelyEnableGestureRecognizer(defaultEdgePanRecognizer)
            case .pan:
                exclusivelyEnableGestureRecognizer(defaultPanRecognizer)
            }
        } else {
            switch interactivity {
            case .disabled:
                exclusivelyEnableGestureRecognizer(.none)
            case .edgePan:
                exclusivelyEnableGestureRecognizer(edgePanRecognizer)
            case .pan:
                exclusivelyEnableGestureRecognizer(panRecognizer)
            }
        }
        #endif
    }

    @available(tvOS, unavailable)
    private func exclusivelyEnableGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer?) {
        for recognizer in [defaultEdgePanRecognizer!, defaultPanRecognizer!, edgePanRecognizer!, panRecognizer!] {
            if let gestureRecognizer = gestureRecognizer, recognizer === gestureRecognizer {
                recognizer.isEnabled = true
            } else {
                recognizer.isEnabled = false
            }
        }
    }
}

@available(tvOS, unavailable)
extension UINavigationController {
    var defaultEdgePanRecognizer: UIScreenEdgePanGestureRecognizer! {
        interactivePopGestureRecognizer as? UIScreenEdgePanGestureRecognizer
    }

    private static var defaultInteractivePanGestureRecognizer = "defaultInteractivePanGestureRecognizer"
    private static var interactiveEdgePanGestureRecognizer = "interactiveEdgePanGestureRecognizer"
    private static var interactivePanGestureRecognizer = "interactivePanGestureRecognizer"

    var defaultPanRecognizer: UIPanGestureRecognizer! {
        get { objc_getAssociatedObject(self, &Self.defaultInteractivePanGestureRecognizer) as? UIPanGestureRecognizer }
        set { objc_setAssociatedObject(self, &Self.defaultInteractivePanGestureRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var edgePanRecognizer: UIScreenEdgePanGestureRecognizer! {
        get { objc_getAssociatedObject(self, &Self.interactiveEdgePanGestureRecognizer) as? UIScreenEdgePanGestureRecognizer }
        set { objc_setAssociatedObject(self, &Self.interactiveEdgePanGestureRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var panRecognizer: UIPanGestureRecognizer! {
        get { objc_getAssociatedObject(self, &Self.interactivePanGestureRecognizer) as? UIPanGestureRecognizer }
        set { objc_setAssociatedObject(self, &Self.interactivePanGestureRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

@available(tvOS, unavailable)
extension UIGestureRecognizer {
    private static var strongDelegateKey = "strongDelegateKey"

    var strongDelegate: UIGestureRecognizerDelegate? {
        get {
            objc_getAssociatedObject(self, &Self.strongDelegateKey) as? UIGestureRecognizerDelegate
        }
        set {
            objc_setAssociatedObject(self, &Self.strongDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = newValue
        }
    }

    var targets: Any? {
        get {
            value(forKey: #function)
        }
        set {
            if let newValue = newValue {
                setValue(newValue, forKey: #function)
            } else {
                setValue(NSMutableArray(), forKey: #function)
            }
        }
    }
}

@available(tvOS, unavailable)
final class NavigationGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    private unowned let navigationController: UINavigationController

    init(controller: UINavigationController) {
        self.navigationController = controller
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isNotOnRoot = navigationController.viewControllers.count > 1
        return isNotOnRoot
    }
}

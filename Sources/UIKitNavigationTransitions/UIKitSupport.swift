import IssueReporting
public import NavigationTransition
public import UIKit

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
			viewController(for: .compact)
		} else {
			if isCollapsed {
				viewControllers.first
			} else {
				nil
			}
		}
	}

	var primaryViewController: UIViewController? {
		if #available(iOS 14, tvOS 14, *) {
			viewController(for: .primary)
		} else {
			if !isCollapsed {
				viewControllers.first
			} else {
				nil
			}
		}
	}

	var supplementaryViewController: UIViewController? {
		if #available(iOS 14, tvOS 14, *) {
			viewController(for: .supplementary)
		} else {
			if !isCollapsed {
				if viewControllers.count >= 3 {
					viewControllers[safe: 1]
				} else {
					nil
				}
			} else {
				nil
			}
		}
	}

	var secondaryViewController: UIViewController? {
		if #available(iOS 14, tvOS 14, *) {
			viewController(for: .secondary)
		} else {
			if !isCollapsed {
				if viewControllers.count >= 3 {
					viewControllers[safe: 2]
				} else {
					viewControllers[safe: 1]
				}
			} else {
				nil
			}
		}
	}
}

extension RandomAccessCollection where Index == Int {
	subscript(safe index: Index) -> Element? {
		self.dropFirst(index).first
	}
}

private struct AssociatedKeys {
    static var defaultDelegate: UInt8 = 0
    static var customDelegate: UInt8 = 0
    static var defaultPanRecognizer: UInt8 = 0
    static var edgePanRecognizer: UInt8 = 0
    static var panRecognizer: UInt8 = 0
    static var strongDelegate: UInt8 = 0
}

extension UINavigationController {
    var defaultDelegate: (any UINavigationControllerDelegate)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.defaultDelegate) as? any UINavigationControllerDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defaultDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var customDelegate: NavigationTransitionDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.customDelegate) as? NavigationTransitionDelegate
        }
        set {
            delegate = newValue
            objc_setAssociatedObject(self, &AssociatedKeys.customDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

	public func setNavigationTransition(
		_ transition: AnyNavigationTransition,
		interactivity: AnyNavigationTransition.Interactivity = .default
	) {
        UINavigationController.enableCustomTransitions()

		if defaultDelegate == nil {
			defaultDelegate = delegate
		}

		if let customDelegate {
			customDelegate.transition = transition
		} else {
			customDelegate = NavigationTransitionDelegate(transition: transition, baseDelegate: defaultDelegate)
		}

		#if !os(tvOS) && !os(visionOS)
		if defaultEdgePanRecognizer.strongDelegate == nil {
			defaultEdgePanRecognizer.strongDelegate = NavigationGestureRecognizerDelegate(controller: self)
		}

		if defaultPanRecognizer == nil {
			defaultPanRecognizer = UIPanGestureRecognizer()
			defaultPanRecognizer.targets = defaultEdgePanRecognizer.targets // https://stackoverflow.com/a/60526328/1922543
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

		if transition.isDefault {
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

    public static func enableCustomTransitions() {
        _ = swizzleOnce
    }

    private static let swizzleOnce: Void = {
        swizzle()
    }()

    private static func swizzle() {
        let originalMethods: [(Selector, Selector)] = [
            (#selector(UINavigationController.setViewControllers(_:animated:)), #selector(swizzled_setViewControllers(_:animated:))),
            (#selector(UINavigationController.pushViewController(_:animated:)), #selector(swizzled_pushViewController(_:animated:))),
            (#selector(UINavigationController.popViewController(animated:)), #selector(swizzled_popViewController(animated:))),
            (#selector(UINavigationController.popToViewController(_:animated:)), #selector(swizzled_popToViewController(_:animated:))),
            (#selector(UINavigationController.popToRootViewController(animated:)), #selector(swizzled_popToRootViewController(animated:)))
        ]

        originalMethods.forEach { originalSelector, swizzledSelector in
            guard let originalMethod = class_getInstanceMethod(self, originalSelector),
                  let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
                return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    @objc private func swizzled_setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if let transitionDelegate = self.customDelegate {
            self.swizzled_setViewControllers(viewControllers, animated: transitionDelegate.transition.animation != nil)
        } else {
            self.swizzled_setViewControllers(viewControllers, animated: animated)
        }
    }

    @objc private func swizzled_pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let transitionDelegate = self.customDelegate {
            self.swizzled_pushViewController(viewController, animated: transitionDelegate.transition.animation != nil)
        } else {
            self.swizzled_pushViewController(viewController, animated: animated)
        }
    }

    @objc private func swizzled_popViewController(animated: Bool) -> UIViewController? {
        if let transitionDelegate = self.customDelegate {
            return self.swizzled_popViewController(animated: transitionDelegate.transition.animation != nil)
        } else {
            return self.swizzled_popViewController(animated: animated)
        }
    }

    @objc private func swizzled_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if let transitionDelegate = self.customDelegate {
            return self.swizzled_popToViewController(viewController, animated: transitionDelegate.transition.animation != nil)
        } else {
            return self.swizzled_popToViewController(viewController, animated: animated)
        }
    }

    @objc private func swizzled_popToRootViewController(animated: Bool) -> [UIViewController]? {
        if let transitionDelegate = self.customDelegate {
            return self.swizzled_popToRootViewController(animated: transitionDelegate.transition.animation != nil)
        } else {
            return self.swizzled_popToRootViewController(animated: animated)
        }
    }


	@available(tvOS, unavailable)
	@available(visionOS, unavailable)
	private func exclusivelyEnableGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer?) {
		for recognizer in [defaultEdgePanRecognizer!, defaultPanRecognizer!, edgePanRecognizer!, panRecognizer!] {
			if let gestureRecognizer, recognizer === gestureRecognizer {
				recognizer.isEnabled = true
			} else {
				recognizer.isEnabled = false
			}
		}
	}
}

@available(tvOS, unavailable)
@available(visionOS, unavailable)
extension UINavigationController {
    var defaultEdgePanRecognizer: UIScreenEdgePanGestureRecognizer! {
        interactivePopGestureRecognizer as? UIScreenEdgePanGestureRecognizer
    }

    var defaultPanRecognizer: UIPanGestureRecognizer! {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.defaultPanRecognizer) as? UIPanGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defaultPanRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var edgePanRecognizer: UIScreenEdgePanGestureRecognizer! {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.edgePanRecognizer) as? UIScreenEdgePanGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.edgePanRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var panRecognizer: UIPanGestureRecognizer! {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.panRecognizer) as? UIPanGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.panRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
@available(tvOS, unavailable)
extension UIGestureRecognizer {
    var strongDelegate: (any UIGestureRecognizerDelegate)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.strongDelegate) as? any UIGestureRecognizerDelegate
        }
        set {
            self.delegate = newValue

            objc_setAssociatedObject(self, &AssociatedKeys.strongDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

	var targets: Any? {
		get {
			value(forKey: #function)
		}
		set {
			if let newValue {
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

	// TODO: swizzle instead
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		let isNotOnRoot = navigationController.viewControllers.count > 1
		let noModalIsPresented = navigationController.presentedViewController == nil // TODO: check if this check is still needed after iOS 17 public release
		return isNotOnRoot && noModalIsPresented
	}
}

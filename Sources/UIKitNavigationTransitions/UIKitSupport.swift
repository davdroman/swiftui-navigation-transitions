import IssueReporting
public import NavigationTransition
import ObjCRuntimeTools
import Once
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

extension UINavigationController {
	@Associated(.retain(.nonatomic))
	private var defaultDelegate: (any UINavigationControllerDelegate)!

	@Associated(.retain(.nonatomic))
	var customDelegate: NavigationTransitionDelegate? {
		didSet {
			delegate = customDelegate
		}
	}

	public func setNavigationTransition(
		_ transition: AnyNavigationTransition,
		interactivity: AnyNavigationTransition.Interactivity = .default
	) {
		if defaultDelegate == nil {
			defaultDelegate = delegate
		}

		if let customDelegate {
			customDelegate.transition = transition
		} else {
			customDelegate = NavigationTransitionDelegate(transition: transition, baseDelegate: defaultDelegate)
		}

		do {
			try UINavigationController.swizzle()
		} catch {
			reportIssue(error, "Failed to swizzle required UINavigationController methods")
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

	private static func swizzle() throws {
		try #once {
			try #swizzle(
				UINavigationController.setViewControllers,
				params: [UIViewController].self, Bool.self
			) { $self, viewControllers, animated in
				if let transitionDelegate = self.customDelegate {
					self.setViewControllers(viewControllers, animated: transitionDelegate.transition.animation != nil)
				} else {
					self.setViewControllers(viewControllers, animated: animated)
				}
			}

			try #swizzle(
				UINavigationController.pushViewController,
				params: UIViewController.self, Bool.self
			) { $self, viewController, animated in
				if let transitionDelegate = self.customDelegate {
					self.pushViewController(viewController, animated: transitionDelegate.transition.animation != nil)
				} else {
					self.pushViewController(viewController, animated: animated)
				}
			}

			try #swizzle(
				UINavigationController.popViewController,
				params: Bool.self,
				returning: UIViewController?.self
			) { $self, animated in
				if let transitionDelegate = self.customDelegate {
					self.popViewController(animated: transitionDelegate.transition.animation != nil)
				} else {
					self.popViewController(animated: animated)
				}
			}

			try #swizzle(
				UINavigationController.popToViewController,
				params: UIViewController.self, Bool.self,
				returning: [UIViewController]?.self
			) { $self, viewController, animated in
				if let transitionDelegate = self.customDelegate {
					self.popToViewController(viewController, animated: transitionDelegate.transition.animation != nil)
				} else {
					self.popToViewController(viewController, animated: animated)
				}
			}

			try #swizzle(
				UINavigationController.popToRootViewController,
				params: Bool.self,
				returning: [UIViewController]?.self
			) { $self, animated in
				if let transitionDelegate = self.customDelegate {
					self.popToRootViewController(animated: transitionDelegate.transition.animation != nil)
				} else {
					self.popToRootViewController(animated: animated)
				}
			}
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

	@Associated(.retain(.nonatomic))
	var defaultPanRecognizer: UIPanGestureRecognizer!

	@Associated(.retain(.nonatomic))
	var edgePanRecognizer: UIScreenEdgePanGestureRecognizer!

	@Associated(.retain(.nonatomic))
	var panRecognizer: UIPanGestureRecognizer!
}

@available(tvOS, unavailable)
extension UIGestureRecognizer {
	@Associated(.retain(.nonatomic))
	var strongDelegate: (any UIGestureRecognizerDelegate)? {
		didSet {
			delegate = strongDelegate
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

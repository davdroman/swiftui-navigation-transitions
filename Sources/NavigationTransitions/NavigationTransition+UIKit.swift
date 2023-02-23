@_spi(package) import NavigationTransition
@_implementationOnly import RuntimeAssociation
@_implementationOnly import RuntimeSwizzling
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
	private var defaultDelegate: UINavigationControllerDelegate! {
		get { self[] }
		set { self[] = newValue }
	}

	var customDelegate: NavigationTransitionDelegate! {
		get { self[] }
		set {
			self[] = newValue
			delegate = newValue
		}
	}

	public func setNavigationTransition(
		_ transition: AnyNavigationTransition,
		interactivity: AnyNavigationTransition.Interactivity = .default
	) {
		backDeploy96852321()

		if defaultDelegate == nil {
			defaultDelegate = delegate
		}

        if customDelegate == nil {
            customDelegate = NavigationTransitionDelegate(transition: transition, baseDelegate: defaultDelegate)
        } else {
            customDelegate.transition = transition
        }

		#if !os(tvOS)
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

	private func backDeploy96852321() {
		func forceAnimatedPopToViewController() {
			swizzle(
				UINavigationController.self,
				#selector(UINavigationController.popToViewController),
				#selector(UINavigationController.popToViewController_forceAnimated)
			)
		}

		if #available(iOS 16.2, macCatalyst 16.2, tvOS 16.2, *) {} else {
			#if targetEnvironment(macCatalyst)
			let major = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
			let minor = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
			if (major, minor) < (13, 1) {
				forceAnimatedPopToViewController()
			}
			#else
			forceAnimatedPopToViewController()
			#endif
		}
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

extension UINavigationController {
	@objc private func popToViewController_forceAnimated(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
		popToViewController_forceAnimated(viewController, animated: true)
	}
}

@available(tvOS, unavailable)
extension UINavigationController {
	var defaultEdgePanRecognizer: UIScreenEdgePanGestureRecognizer! {
		interactivePopGestureRecognizer as? UIScreenEdgePanGestureRecognizer
	}

	var defaultPanRecognizer: UIPanGestureRecognizer! {
		get { self[] }
		set { self[] = newValue }
	}

	var edgePanRecognizer: UIScreenEdgePanGestureRecognizer! {
		get { self[] }
		set { self[] = newValue }
	}

	var panRecognizer: UIPanGestureRecognizer! {
		get { self[] }
		set { self[] = newValue }
	}
}

@available(tvOS, unavailable)
extension UIGestureRecognizer {
	var strongDelegate: UIGestureRecognizerDelegate? {
		get { self[] }
		set {
			self[] = newValue
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

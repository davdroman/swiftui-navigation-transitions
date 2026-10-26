import SwiftUI
import UIKit
import UIKitNavigationTransitions

@main
struct ProbeApp: App {
	@StateObject private var model = ProbeModel()
	var body: some Scene {
		WindowGroup { NavigationHost(model: model) }
	}
}

@MainActor
final class ProbeModel: NSObject, ObservableObject, UINavigationControllerDelegate {
	@Published var taps: [String: Int] = [:]
	@Published var status = "starting"
	@Published var trace = ""
	weak var navigation: UINavigationController? = nil
	var cancellations = 0
	var completedCancellations = 0
	var completedTransitions = 0
	var keyboardVisible = false
	var transitionViews: [UIView] = []

	private var coordinatorActive: Bool {
		navigation?.transitionCoordinator != nil || navigation?.topViewController?.transitionCoordinator != nil
	}

	private var transitionAnimations: Int {
		transitionViews.reduce(0) { $0 + ($1.layer.animationKeys()?.count ?? 0) }
	}

	override init() {
		super.init()
		UserDefaults.standard.removeObject(forKey: "NavigationABLibraryTrace")
		UserDefaults.standard.removeObject(forKey: "NavigationABAppTrace")
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardShown),
			name: UIResponder.keyboardDidShowNotification,
			object: nil,
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardHidden),
			name: UIResponder.keyboardDidHideNotification,
			object: nil,
		)
	}

	@objc private func keyboardShown() { keyboardVisible = true; record("keyboardDidShow") }
	@objc private func keyboardHidden() { keyboardVisible = false; record("keyboardDidHide") }

	func exportTrace() {
		trace += "\nLIBRARY TRACE\n" + (UserDefaults.standard.stringArray(forKey: "NavigationABLibraryTrace") ?? [])
			.joined(separator: "\n")
	}

	func controller(_ name: String) -> UIViewController {
		let controller = UIHostingController(rootView: ProbeScreen(model: self, name: name))
		controller.title = name
		return controller
	}

	func record(_ event: String) {
		let top = navigation?.topViewController
		let focused = top?.view.firstResponder != nil
		let inNavigation = navigation.map { top?.view.isDescendant(of: $0.view) ?? false } ?? false
		status = "depth=\(navigation?.viewControllers.count ?? 0);top=\(top?.title ?? "nil");cancelled=\(cancellations);completedCancellations=\(completedCancellations);completedTransitions=\(completedTransitions);focused=\(focused);keyboard=\(keyboardVisible);attached=\(top?.view.window != nil);interactive=\(top?.view.isUserInteractionEnabled ?? false);inNavigation=\(inNavigation);coordinatorActive=\(coordinatorActive);transitionAnimations=\(transitionAnimations)"
		let geometry = event.hasPrefix("afterTransition") ? top?.view.diagnosticAncestry ?? "nil" : ""
		let entry = "\(ProcessInfo.processInfo.systemUptime) \(event) \(status) \(geometry)"
		trace += entry + "\n"
		UserDefaults.standard.set(trace, forKey: "NavigationABAppTrace")
		NSLog("[NAV-AB] %@", entry)
	}

	func navigationController(
		_ navigationController: UINavigationController,
		willShow viewController: UIViewController,
		animated: Bool,
	) {
		record("willShow \(viewController.title ?? "nil")")
		if let coordinator = navigationController.transitionCoordinator {
			transitionViews = [coordinator.view(forKey: .from), coordinator.view(forKey: .to), coordinator.containerView]
				.compactMap(\.self)
		}
		navigationController.transitionCoordinator?.notifyWhenInteractionChanges { context in
			if context.isCancelled { self.cancellations += 1 }
			self.record("interactionChanged cancelled=\(context.isCancelled)")
		}
		navigationController.transitionCoordinator?.animate(alongsideTransition: nil) { context in
			let cancelled = context.isCancelled
			self.completedTransitions += 1
			if cancelled { self.completedCancellations += 1 }
			self.record("transitionCompletion cancelled=\(cancelled)")
			Task { @MainActor in
				let deadline = ProcessInfo.processInfo.systemUptime + 3
				while self.coordinatorActive || self.transitionAnimations != 0 {
					if ProcessInfo.processInfo.systemUptime >= deadline { break }
					await Task.yield()
				}
				self.record("afterTransition cancelled=\(cancelled)")
			}
		}
	}

	func navigationController(
		_ navigationController: UINavigationController,
		didShow viewController: UIViewController,
		animated: Bool,
	) {
		record("didShow \(viewController.title ?? "nil")")
		DispatchQueue.main.async { self.record("afterDidShow") }
	}
}

extension UIView {
	fileprivate var diagnosticAncestry: String {
		var current: UIView? = self
		var entries: [String] = []
		while let view = current {
			let gestures = (view.gestureRecognizers ?? [])
				.map { "\(type(of: $0)):state=\($0.state.rawValue):enabled=\($0.isEnabled)" }
			entries
				.append(
					"\(type(of: view)):frame=\(view.frame):bounds=\(view.bounds):transform=\(view.transform):presentation=\(String(describing: view.layer.presentation()?.frame)):interactive=\(view.isUserInteractionEnabled):hidden=\(view.isHidden):alpha=\(view.alpha):gestures=\(gestures)",
				)
			current = view.superview
		}
		return entries.joined(separator: " -> ")
	}

	fileprivate var firstResponder: UIView? {
		if isFirstResponder { return self }
		return subviews.lazy.compactMap(\.firstResponder).first
	}
}

struct NavigationHost: UIViewControllerRepresentable {
	let model: ProbeModel
	func makeUIViewController(context: Context) -> UINavigationController {
		let navigation = UINavigationController(rootViewController: model.controller("root"))
		model.navigation = navigation
		navigation.delegate = model
		if ProcessInfo.processInfo.environment["NAVIGATION_AB_TRANSITION"] != "native" {
			navigation.setNavigationTransition(.slide, interactivity: .edgePan)
		}
		return navigation
	}
	func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct ProbeScreen: View {
	@ObservedObject var model: ProbeModel
	let name: String
	@State private var text = ""
	var body: some View {
		VStack(spacing: 12) {
			Text(name).accessibilityIdentifier("screen-\(name)")
			Text(model.status).font(.caption2).accessibilityIdentifier("status")
			if name != "root" {
				TextField("Input", text: $text)
					.textFieldStyle(.roundedBorder)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
					.accessibilityIdentifier("field-\(name)")
					.onChange(of: text) { _ in model.record("textChanged \(name)") }
			}
			Button("Tap \(name)") {
				model.taps[name, default: 0] += 1
				model.record("tap \(name)")
			}.accessibilityIdentifier("tap-\(name)")
			Text("\(model.taps[name, default: 0])").accessibilityIdentifier("count-\(name)")
			if name != "detail" {
				Button("Push") {
					model.navigation?.pushViewController(model.controller(name == "root" ? "source" : "detail"), animated: true)
				}.accessibilityIdentifier("push-\(name)")
			}
			if name != "root" {
				Button("Pop") { model.navigation?.popViewController(animated: true) }
					.accessibilityIdentifier("pop-\(name)")
			}
			Text("Trace").font(.caption2).accessibilityLabel(model.trace).accessibilityIdentifier("trace")
			Button("Export trace") { model.exportTrace() }.accessibilityIdentifier("export")
			Spacer(minLength: 0)
		}
		.buttonStyle(.borderedProminent)
		.padding()
	}
}

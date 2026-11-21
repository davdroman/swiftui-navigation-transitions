import UIKit

/// The host app's key window, showing a test's view controller until `restore()` is called.
@MainActor
final class TestWindow {
	let window: UIWindow
	private let originalRoot: UIViewController?

	init(rootViewController: UIViewController) async throws {
		window = try await waitUntilValue { Self.activeWindow }
		originalRoot = window.rootViewController
		window.rootViewController = rootViewController
		window.makeKeyAndVisible()
		window.layoutIfNeeded()
		try await waitUntil { rootViewController.viewIfLoaded?.window != nil }
	}

	func restore() {
		window.rootViewController = originalRoot
		window.layoutIfNeeded()
	}

	private static var activeWindow: UIWindow? {
		UIApplication.shared
			.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.filter { $0.activationState == .foregroundActive }
			.flatMap(\.windows)
			.first { $0.isKeyWindow }
	}
}

struct TimeoutError: Error, CustomStringConvertible {
	var description: String { "Timed out waiting for a condition" }
}

/// Waits until `condition` holds, checking it as the main run loop turns.
@MainActor
func waitUntil(timeout: Duration = .seconds(3), _ condition: () -> Bool) async throws {
	_ = try await waitUntilValue(timeout: timeout) { condition() ? () : nil }
}

/// Waits until `value` returns a non-`nil` value, and returns it.
@MainActor
func waitUntilValue<Value>(timeout: Duration = .seconds(3), _ value: () -> Value?) async throws -> Value {
	let deadline = ContinuousClock.now + timeout
	while true {
		if let value = value() {
			return value
		}
		guard ContinuousClock.now < deadline else {
			throw TimeoutError()
		}
		try await Task.sleep(for: .milliseconds(10))
	}
}

#if os(tvOS)
final class FocusResponder: UIView {
	override var canBecomeFirstResponder: Bool { true }
}
#else
typealias FocusResponder = UITextField
#endif

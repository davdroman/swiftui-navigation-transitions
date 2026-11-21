import UIKit
import XCTest

@MainActor
final class TestWindow {
	let window: UIWindow
	private let originalRoot: UIViewController?

	init(rootViewController: UIViewController, test: XCTestCase) async throws {
		let ready = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
			MainActor.assumeIsolated { Self.activeWindow != nil }
		}, object: nil)
		await test.fulfillment(of: [ready], timeout: 3)
		window = try XCTUnwrap(Self.activeWindow)
		originalRoot = window.rootViewController
		window.rootViewController = rootViewController
		window.makeKeyAndVisible()
		window.layoutIfNeeded()
		let attached = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
			MainActor.assumeIsolated { rootViewController.viewIfLoaded?.window != nil }
		}, object: nil)
		await test.fulfillment(of: [attached], timeout: 3)
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

#if os(tvOS)
final class FocusResponder: UIView {
	override var canBecomeFirstResponder: Bool { true }
}
#else
typealias FocusResponder = UITextField
#endif

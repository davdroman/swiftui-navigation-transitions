#if !os(tvOS) && !os(visionOS)
import Testing
import UIKit
@testable import UIKitNavigationTransitions

@MainActor
struct GestureRecognizerTests {
	@available(iOS 26, macCatalyst 26, *)
	@Test
	func `default interactivity uses system recognizer`() throws {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.default)

		let contentPopGestureRecognizer = try #require(
			navigationController.interactiveContentPopGestureRecognizer,
		)

		#expect(navigationController.defaultEdgePanRecognizer.isEnabled)
		#expect(contentPopGestureRecognizer.isEnabled)
		#expect(navigationController.defaultPanRecognizer == nil)
		#expect(!navigationController.edgePanRecognizer.isEnabled)
		#expect(!navigationController.panRecognizer.isEnabled)
	}

	@available(iOS 26, macCatalyst 26, *)
	@Test
	func `default edge pan disables content recognizer`() throws {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.default, interactivity: .edgePan)

		let contentPopGestureRecognizer = try #require(
			navigationController.interactiveContentPopGestureRecognizer,
		)

		#expect(navigationController.defaultEdgePanRecognizer.isEnabled)
		#expect(!contentPopGestureRecognizer.isEnabled)
		#expect(!navigationController.edgePanRecognizer.isEnabled)
		#expect(!navigationController.panRecognizer.isEnabled)
	}

	@available(iOS 26, macCatalyst 26, *)
	@Test
	func `disabled interactivity disables system recognizers`() throws {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.default, interactivity: .disabled)

		let contentPopGestureRecognizer = try #require(
			navigationController.interactiveContentPopGestureRecognizer,
		)

		#expect(!navigationController.defaultEdgePanRecognizer.isEnabled)
		#expect(!contentPopGestureRecognizer.isEnabled)
		#expect(!navigationController.edgePanRecognizer.isEnabled)
		#expect(!navigationController.panRecognizer.isEnabled)
	}

	@available(iOS 26, macCatalyst 26, *)
	@Test
	func `disabled custom transition disables all pop recognizers`() throws {
		let navigationController = makeNavigationController()
		navigationController.setNavigationTransition(.slide, interactivity: .disabled)
		let contentPopGestureRecognizer = try #require(navigationController.interactiveContentPopGestureRecognizer)
		#expect(!navigationController.defaultEdgePanRecognizer.isEnabled)
		#expect(!contentPopGestureRecognizer.isEnabled)
		#expect(navigationController.defaultPanRecognizer?.isEnabled != true)
		#expect(!navigationController.edgePanRecognizer.isEnabled)
		#expect(!navigationController.panRecognizer.isEnabled)
	}

	@available(iOS 26, macCatalyst 26, *)
	@Test
	func `custom content pan uses custom recognizer`() throws {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.slide, interactivity: .contentPan)

		let contentPopGestureRecognizer = try #require(
			navigationController.interactiveContentPopGestureRecognizer,
		)

		#expect(!navigationController.defaultEdgePanRecognizer.isEnabled)
		#expect(!contentPopGestureRecognizer.isEnabled)
		#expect(!navigationController.edgePanRecognizer.isEnabled)
		#expect(navigationController.panRecognizer.isEnabled)
	}

	@Test
	func `a transition can be set before the view loads`() {
		let navigationController = UINavigationController()

		navigationController.setNavigationTransition(.slide, interactivity: .edgePan)

		#expect(navigationController.edgePanRecognizer.isEnabled)
		#expect(!navigationController.panRecognizer.isEnabled)
	}

	@Test(.enabled(if: !isOS26OrLater, "From iOS 26, the system's own recognizers pan across the content"), arguments: [
		(Mode.disabled, Recognizer?.none),
		(.edgePan, .defaultEdgePan),
		(.contentPan, .defaultPan),
	])
	func `before iOS 26, the default transition enables the system or library recognizer`(
		mode: Mode,
		expected: Recognizer?,
	) {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.default, interactivity: mode.interactivity)

		#expect(enabledRecognizers(navigationController) == Set([expected].compactMap(\.self)))
	}

	@Test(arguments: [
		(Mode.disabled, Recognizer?.none),
		(.edgePan, .edgePan),
		(.contentPan, .pan),
	])
	func `custom transitions enable the library's recognizer`(mode: Mode, expected: Recognizer?) {
		let navigationController = makeNavigationController()

		navigationController.setNavigationTransition(.slide, interactivity: mode.interactivity)

		#expect(enabledRecognizers(navigationController) == Set([expected].compactMap(\.self)))
	}

	enum Recognizer: Hashable, Sendable {
		case defaultEdgePan
		case defaultPan
		case contentPop
		case edgePan
		case pan
	}

	enum Mode: Sendable {
		case disabled
		case edgePan
		case contentPan

		var interactivity: CustomNavigationTransition.Interactivity {
			switch self {
			case .disabled: .disabled
			case .edgePan: .edgePan
			case .contentPan: .contentPan
			}
		}
	}

	private func enabledRecognizers(_ navigationController: UINavigationController) -> Set<Recognizer> {
		var recognizers: [(Recognizer, UIGestureRecognizer?)] = [
			(.defaultEdgePan, navigationController.defaultEdgePanRecognizer),
			(.defaultPan, navigationController.defaultPanRecognizer),
			(.edgePan, navigationController.edgePanRecognizer),
			(.pan, navigationController.panRecognizer),
		]
		if #available(iOS 26, macCatalyst 26, *) {
			recognizers.append((.contentPop, navigationController.interactiveContentPopGestureRecognizer))
		}
		return Set(recognizers.filter { $0.1?.isEnabled == true }.map(\.0))
	}

	private func makeNavigationController() -> UINavigationController {
		let navigationController = UINavigationController()
		navigationController.setViewControllers(
			[UIViewController(), UIViewController()],
			animated: false,
		)
		navigationController.loadViewIfNeeded()
		return navigationController
	}
}

private let isOS26OrLater =
	if #available(iOS 26, macCatalyst 26, *) {
		true
	} else {
		false
	}
#endif

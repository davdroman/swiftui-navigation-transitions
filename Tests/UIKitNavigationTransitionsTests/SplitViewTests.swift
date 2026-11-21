import Testing
import UIKit
@testable import UIKitNavigationTransitions

@MainActor
struct SplitViewTests {
	nonisolated static let cases: [(UISplitViewControllerColumns, [String])] = [
		(.primary, ["primary"]),
		(.supplementary, ["supplementary"]),
		(.secondary, ["secondary"]),
		(.compact, ["compact"]),
		([.primary, .secondary], ["primary", "secondary"]),
		(.all, ["primary", "supplementary", "secondary", "compact"]),
	]

	@Test(arguments: cases)
	func `the transition applies to the given columns`(columns: UISplitViewControllerColumns, expected: [String]) {
		let splitViewController = UISplitViewController(style: .tripleColumn)
		let navigationControllers: [String: UINavigationController] = [
			"primary": UINavigationController(),
			"supplementary": UINavigationController(),
			"secondary": UINavigationController(),
			"compact": UINavigationController(),
		]
		splitViewController.setViewController(navigationControllers["primary"], for: .primary)
		splitViewController.setViewController(navigationControllers["supplementary"], for: .supplementary)
		splitViewController.setViewController(navigationControllers["secondary"], for: .secondary)
		splitViewController.setViewController(navigationControllers["compact"], for: .compact)

		splitViewController.setNavigationTransition(.slide, forColumns: columns)

		let configured = Set(navigationControllers.filter { $0.value.customDelegate != nil }.keys)
		#expect(configured == Set(expected))
	}
}

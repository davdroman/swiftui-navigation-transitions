import XCTest

/// Pushes and pops in the demo app, through the same touches a person makes.
@MainActor
final class DemoUITests: XCTestCase {
	private var app: XCUIApplication! = nil

	override func setUp() async throws {
		continueAfterFailure = false
	}

	func testLinksPushAndTheBackButtonPops() {
		launch(transition: "Slide", interactivity: "Disabled")

		app.buttons["Show me!"].tap()
		XCTAssertTrue(page("Overview").waitForExistence(timeout: 5))

		page("Overview").buttons.element(boundBy: 0).tap()
		XCTAssertTrue(page("Welcome").waitForExistence(timeout: 5))
	}

	func testEdgePanPopsFromTheEdgeOnly() {
		launch(transition: "Slide", interactivity: "Edge Pan")
		pushOverview()

		swipeAcrossContent()
		expectStaysOnOverview()

		swipeFromEdge()
		expectPopsToWelcome()
	}

	func testContentPanPopsFromAnywhere() {
		launch(transition: "Slide", interactivity: "Content Pan")
		pushOverview()

		swipeAcrossContent()
		expectPopsToWelcome()
	}

	func testDisabledInteractivityDoesNotPop() {
		launch(transition: "Slide", interactivity: "Disabled")
		pushOverview()

		swipeAcrossContent()
		swipeFromEdge()
		expectStaysOnOverview()
	}

	func testShortSlowSwipeCancelsThePop() {
		launch(transition: "Slide", interactivity: "Content Pan")
		pushOverview()

		// Moves a twentieth of the width, then rests before lifting.
		drag(from: 0.4, to: 0.45, pressing: 0, velocity: .slow, holding: 0.5)
		expectStaysOnOverview()

		swipeAcrossContent()
		expectPopsToWelcome()
	}

	func testDefaultTransitionPopsFromTheEdge() {
		launch(transition: "Default", interactivity: "Edge Pan")
		pushOverview()

		swipeFromEdge()
		expectPopsToWelcome()
	}

	func testDefaultTransitionWithContentPanPopsFromAnywhere() {
		launch(transition: "Default", interactivity: "Content Pan")
		pushOverview()

		swipeAcrossContent()
		expectPopsToWelcome()
	}

	func testDefaultTransitionWithDisabledInteractivityDoesNotPop() {
		launch(transition: "Default", interactivity: "Disabled")
		pushOverview()

		swipeAcrossContent()
		swipeFromEdge()
		expectStaysOnOverview()
	}

	func testChangingToTheDefaultTransitionKeepsSwipingBack() {
		launch(transition: "Slide", interactivity: "Content Pan")

		app.buttons["Settings"].tap()
		app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Transition")).firstMatch.tap()
		app.buttons["Default"].tap()
		app.buttons["Done"].tap()
		XCTAssertTrue(app.buttons["Done"].waitForNonExistence(timeout: 5))
		pushOverview()

		swipeAcrossContent()
		expectPopsToWelcome()
	}

	// MARK: Helpers

	private func launch(transition: String, interactivity: String) {
		app = XCUIApplication()
		app.launchArguments = [
			"-transition", transition,
			"-animation", "Ease In Out",
			"-duration", "Fast",
			"-interactivity", interactivity,
		]
		app.launch()
		XCTAssertTrue(page("Welcome").waitForExistence(timeout: 10))
	}

	private func page(_ title: String) -> XCUIElement {
		app.navigationBars[title]
	}

	private func pushOverview() {
		app.buttons["Show me!"].tap()
		XCTAssertTrue(page("Overview").waitForExistence(timeout: 5))
		// Let the push finish before swiping back.
		XCTAssertTrue(page("Welcome").waitForNonExistence(timeout: 5))
	}

	/// Swipes right from the leading edge of the screen.
	///
	/// The system's edge recognizer begins only for some synthesized touches, and which ones depends on the iOS version:
	/// iOS 17 needs a brief press and a fast drag, and later versions a touch that rests on the edge before moving.
	private func swipeFromEdge() {
		if #available(iOS 18, *) {
			drag(from: 0, to: 0.6, pressing: 0.3, velocity: .default, holding: 0)
		} else {
			drag(from: 0, to: 0.6, pressing: 0.05, velocity: .fast, holding: 0)
		}
	}

	/// Swipes right across the middle of the screen.
	private func swipeAcrossContent() {
		app.swipeRight()
	}

	/// Drags horizontally across the middle of the screen, between fractions of its width.
	private func drag(
		from startX: CGFloat,
		to endX: CGFloat,
		pressing press: TimeInterval,
		velocity: XCUIGestureVelocity,
		holding hold: TimeInterval,
	) {
		let start = app.coordinate(withNormalizedOffset: CGVector(dx: startX, dy: 0.5))
		let end = app.coordinate(withNormalizedOffset: CGVector(dx: endX, dy: 0.5))
		start.press(forDuration: press, thenDragTo: end, withVelocity: velocity, thenHoldForDuration: hold)
	}

	private func expectPopsToWelcome(file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertTrue(page("Welcome").waitForExistence(timeout: 5), file: file, line: line)
		XCTAssertTrue(page("Overview").waitForNonExistence(timeout: 5), file: file, line: line)
	}

	private func expectStaysOnOverview(file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertFalse(page("Welcome").waitForExistence(timeout: 1.5), file: file, line: line)
		XCTAssertTrue(page("Overview").exists, file: file, line: line)
	}
}

import XCTest

@MainActor
final class ProbeUITests: XCTestCase {
	func testBaseline() { exercise(variant: "baseline") }
	func testWithoutReattachment() { exercise(variant: "no-reattach") }

	private func exercise(variant: String) {
		continueAfterFailure = true
		let app = XCUIApplication()
		app.launchEnvironment["NAVIGATION_AB_VARIANT"] = variant
		app.launch()
		defer {
			app.buttons["export"].tap()
			let events = app.staticTexts["trace"].label
			XCTAssertTrue(events.contains("beforeCompleteTransition"))
			XCTAssertTrue(events.contains("variant=\(variant)"))
			if #unavailable(iOS 17) {
				XCTAssertTrue(events.contains(variant == "baseline" ? "afterReattach" : "candidateSkippedReattachment"))
			}
			let trace = XCTAttachment(string: events)
			trace.name = "\(variant)-event-trace"
			trace.lifetime = .keepAlways
			add(trace)
			let screenshot = XCTAttachment(screenshot: app.screenshot())
			screenshot.lifetime = .keepAlways
			add(screenshot)
			app.terminate()
		}
		XCTAssertTrue(app.buttons["push-root"].waitForExistence(timeout: 10))
		app.buttons["push-root"].tap()
		expect(app, "top=source")
		let field = app.textFields["field-source"]
		XCTAssertTrue(field.waitForExistence(timeout: 5))
		field.tap()
		field.typeText("seed")
		XCTAssertEqual(field.value as? String, "seed")
		expect(app, "focused=true")
		XCTAssertTrue(app.keyboards.firstMatch.exists)

		for cancellation in 1...3 {
			let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.005, dy: 0.35))
			let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.35))
			start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 1)
			expect(app, "cancelled=\(cancellation)")
			expect(app, "depth=2;top=source")
			expect(app, "attached=true;interactive=true")
			expect(app, "inNavigation=true")
			XCTAssertEqual(app.textFields.matching(identifier: "field-source").count, 1)
			let beforeTaps = XCTAttachment(string: app.staticTexts["status"].label)
			beforeTaps.name = "\(variant)-after-cancel-\(cancellation)"
			beforeTaps.lifetime = .keepAlways
			add(beforeTaps)
			XCTAssertTrue(app.keyboards.firstMatch.exists, "Keyboard disappeared after cancellation")
			expect(app, "focused=true")
			if app.keyboards.firstMatch.exists {
				app.typeText("x")
				XCTAssertEqual(field.value as? String, "seed" + String(repeating: "x", count: cancellation))
			}
			for tap in 1...3 {
				app.buttons["tap-source"].tap()
				XCTAssertEqual(app.staticTexts["count-source"].label, "\((cancellation - 1) * 3 + tap)")
			}
		}

		app.buttons["push-source"].tap()
		expect(app, "depth=3;top=detail")
		app.buttons["tap-detail"].tap()
		XCTAssertEqual(app.staticTexts["count-detail"].label, "1")
		app.buttons["pop-detail"].tap()
		expect(app, "depth=2;top=source")
		app.buttons["tap-source"].tap()
		XCTAssertEqual(app.staticTexts["count-source"].label, "10")
		app.buttons["pop-source"].tap()
		expect(app, "depth=1;top=root")
		app.buttons["tap-root"].tap()
		XCTAssertEqual(app.staticTexts["count-root"].label, "1")
		XCTAssertFalse(app.keyboards.firstMatch.exists)
	}

	private func expect(_ app: XCUIApplication, _ fragment: String, file: StaticString = #filePath, line: UInt = #line) {
		let condition = NSPredicate(format: "label CONTAINS %@", fragment)
		let expectation = XCTNSPredicateExpectation(predicate: condition, object: app.staticTexts["status"])
		XCTAssertEqual(
			XCTWaiter.wait(for: [expectation], timeout: 5),
			.completed,
			"Missing \(fragment): \(app.staticTexts["status"].label)",
			file: file,
			line: line,
		)
	}
}

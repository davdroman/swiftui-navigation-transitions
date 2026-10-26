import XCTest

@MainActor
final class ProbeUITests: XCTestCase {
	func testBaselineFocused() { exercise(variant: "baseline", focused: true) }
	func testBaselineUnfocused() { exercise(variant: "baseline", focused: false) }
	func testWithoutReattachmentFocused() { exercise(variant: "no-reattach", focused: true) }
	func testWithoutReattachmentUnfocused() { exercise(variant: "no-reattach", focused: false) }
	func testNativeUnfocused() { exercise(variant: "baseline", focused: false, native: true) }

	private func exercise(variant: String, focused: Bool, native: Bool = false) {
		continueAfterFailure = true
		let scenario = focused ? "focused" : "unfocused"
		let app = XCUIApplication()
		app.launchEnvironment["NAVIGATION_AB_VARIANT"] = variant
		app.launchEnvironment["NAVIGATION_AB_TRANSITION"] = native ? "native" : "custom"
		app.launch()
		defer {
			tapButton("export", in: app)
			let events = app.staticTexts["trace"].label
			if native {
				XCTAssertFalse(events.contains("beforeCompleteTransition"))
			} else {
				XCTAssertTrue(events.contains("beforeCompleteTransition"))
				XCTAssertTrue(events.contains("variant=\(variant)"))
				if #unavailable(iOS 17) {
					XCTAssertTrue(events.contains(variant == "baseline" ? "afterReattach" : "candidateSkippedReattachment"))
				}
			}
			let trace = XCTAttachment(string: events)
			trace.name = "\(native ? "native" : variant)-\(scenario)-event-trace"
			trace.lifetime = .keepAlways
			add(trace)
			let screenshot = XCTAttachment(screenshot: app.screenshot())
			screenshot.lifetime = .keepAlways
			add(screenshot)
			app.terminate()
		}
		XCTAssertTrue(app.buttons["push-root"].waitForExistence(timeout: 10))
		guard tapButton("push-root", in: app) else { return }
		expect(app, "top=source")
		let field = app.textFields["field-source"]
		XCTAssertTrue(field.waitForExistence(timeout: 5))

		for cancellation in 1...3 {
			guard
				expect(
					app,
					all: [
						"depth=2;top=source;",
						"attached=true;interactive=true;",
						"coordinatorActive=false;transitionAnimations=0",
					],
				)
			else { return }
			if focused {
				field.tap()
				let existingText = field.value as? String ?? ""
				if existingText != "Input", !existingText.isEmpty {
					field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: existingText.count))
				}
				field.typeText("seed")
				XCTAssertEqual(field.value as? String, "seed")
				XCTAssertTrue(app.keyboards.firstMatch.exists)
				guard
					expect(app, "focused=true"), field.value as? String == "seed",
					app.keyboards.firstMatch.exists
				else { return }
			} else {
				XCTAssertFalse(app.keyboards.firstMatch.exists)
				guard
					expect(app, "focused=false"), expect(app, "keyboard=false"),
					!app.keyboards.firstMatch.exists
				else { return }
			}
			if cancellation == 1 {
				guard tapButton("tap-source", in: app) else { return }
				XCTAssertEqual(
					app.staticTexts["count-source"].label,
					"1",
					"Initial touch delivery must work before testing cancellation",
				)
				guard app.staticTexts["count-source"].label == "1" else { return }
			}
			let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.005, dy: 0.35))
			let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.35))
			start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 1)
			guard
				expect(app, all: [
					"cancelled=\(cancellation);",
					"completedCancellations=\(cancellation);",
					"depth=2;top=source;",
					"attached=true;interactive=true;inNavigation=true;",
					"coordinatorActive=false;transitionAnimations=0",
				])
			else { return }
			XCTAssertEqual(app.textFields.matching(identifier: "field-source").count, 1)
			let beforeTaps = XCTAttachment(string: app.staticTexts["status"].label)
			beforeTaps.name = "\(variant)-\(scenario)-after-cancel-\(cancellation)"
			beforeTaps.lifetime = .keepAlways
			add(beforeTaps)
			if focused {
				XCTAssertTrue(app.keyboards.firstMatch.exists, "Keyboard disappeared after cancellation")
				expect(app, "focused=true")
				if app.keyboards.firstMatch.exists {
					app.typeText("x")
					XCTAssertEqual(field.value as? String, "seedx")
				}
			} else {
				XCTAssertFalse(app.keyboards.firstMatch.exists)
				expect(app, "focused=false")
			}
			for tap in 1...3 {
				guard tapButton("tap-source", in: app) else { return }
				XCTAssertEqual(app.staticTexts["count-source"].label, "\(1 + (cancellation - 1) * 3 + tap)")
			}
		}

		guard tapButton("push-source", in: app) else { return }
		guard expect(app, "depth=3;top=detail") else { return }
		guard tapButton("tap-detail", in: app) else { return }
		XCTAssertEqual(app.staticTexts["count-detail"].label, "1")
		guard tapButton("pop-detail", in: app) else { return }
		expect(app, "depth=2;top=source")
		guard tapButton("tap-source", in: app) else { return }
		XCTAssertEqual(app.staticTexts["count-source"].label, "11")
		guard tapButton("pop-source", in: app) else { return }
		expect(app, "depth=1;top=root")
		guard tapButton("tap-root", in: app) else { return }
		XCTAssertEqual(app.staticTexts["count-root"].label, "1")
		XCTAssertFalse(app.keyboards.firstMatch.exists)
	}

	@discardableResult
	private func tapButton(_ identifier: String, in app: XCUIApplication) -> Bool {
		let button = app.buttons[identifier]
		XCTAssertTrue(button.exists)
		guard button.exists else { return false }
		let frame = button.frame
		let point = CGPoint(x: frame.midX, y: frame.midY)
		let valid = !frame.isEmpty && frame.contains(point) && app.frame.contains(point)
		XCTAssertTrue(valid, "Cannot inject a tap: \(identifier) frame=\(frame), point=\(point), appFrame=\(app.frame)")
		guard valid else { return false }
		print("[NAV-AB-INPUT] \(identifier) accessibilityFrame=\(frame) tap=\(point)")
		app.coordinate(withNormalizedOffset: .zero)
			.withOffset(CGVector(dx: point.x - app.frame.minX, dy: point.y - app.frame.minY))
			.tap()
		return true
	}

	@discardableResult
	private func expect(
		_ app: XCUIApplication,
		_ fragment: String,
		file: StaticString = #filePath,
		line: UInt = #line,
	) -> Bool {
		expect(app, all: [fragment], file: file, line: line)
	}

	@discardableResult
	private func expect(
		_ app: XCUIApplication,
		all fragments: [String],
		file: StaticString = #filePath,
		line: UInt = #line,
	) -> Bool {
		let condition = NSPredicate { object, _ in
			MainActor.assumeIsolated {
				guard let element = object as? XCUIElement else { return false }
				let snapshot = element.label
				return fragments.allSatisfy { snapshot.contains($0) }
			}
		}
		let expectation = XCTNSPredicateExpectation(predicate: condition, object: app.staticTexts["status"])
		let result = XCTWaiter.wait(for: [expectation], timeout: 5)
		XCTAssertEqual(
			result,
			.completed,
			"Missing \(fragments): \(app.staticTexts["status"].label)",
			file: file,
			line: line,
		)
		return result == .completed
	}
}

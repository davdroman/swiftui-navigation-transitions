@_spi(package) @testable import Animator
import UIKit
import XCTest

final class AnimatorTransientViewPropertiesTests: XCTestCase {}

extension AnimatorTransientViewPropertiesTests {
    func testInitAndSet() {
        var sut = AnimatorTransientView.Properties(alpha: 0.5, transform: .identity)
        XCTAssertEqual(sut.$alpha, nil)
        XCTAssertEqual(sut.alpha, 0.5)
        XCTAssertEqual(sut.$transform, nil)
        XCTAssertEqual(sut.transform, .identity)

        sut.alpha = 0.3
        XCTAssertEqual(sut.$alpha, 0.3)
        XCTAssertEqual(sut.alpha, 0.3)
        sut.transform = .identity.rotated(by: .pi)
        XCTAssertEqual(sut.$transform, .identity.rotated(by: .pi))
        XCTAssertEqual(sut.transform, .identity.rotated(by: .pi))
    }
}

extension AnimatorTransientViewPropertiesTests {
    func testTransformComponents() {
        var sut = AnimatorTransientView.Properties(alpha: 0.5, transform: .identity)

        sut.translation = .init(dx: 10, dy: 20)
        sut.scale = .init(width: 30, height: 40)
        sut.rotation = .pi

        XCTAssertEqual(sut.translation, .init(dx: 10, dy: 20))
        XCTAssertEqual(sut.scale, .init(width: 30, height: 40))
        XCTAssertEqual(sut.rotation, .pi)

        XCTAssertEqual(
            sut.transform,
            .identity.translatedBy(x: 10, y: 20).scaledBy(x: 30, y: 40).rotated(by: .pi)
        )
    }
}

extension AnimatorTransientViewTests {
    func testTransformComponents_negativeX() {
        var sut = AnimatorTransientView.Properties(alpha: 0.5, transform: .identity)

        sut.translation = .init(dx: -10, dy: 20)
        sut.scale = .init(width: 30, height: 40)
        sut.rotation = .pi

        XCTAssertEqual(sut.translation, .init(dx: -10, dy: 20))
        XCTAssertEqual(sut.scale, .init(width: 30, height: 40))
        XCTAssertEqual(sut.rotation, .pi)

        XCTAssertEqual(
            sut.transform,
            .identity.translatedBy(x: -10, y: 20).scaledBy(x: 30, y: 40).rotated(by: .pi)
        )
    }

    func testTransformComponents_negativeY() {
        var sut = AnimatorTransientView.Properties(alpha: 0.5, transform: .identity)

        sut.translation = .init(dx: 10, dy: -20)
        sut.scale = .init(width: 30, height: 40)
        sut.rotation = .pi

        XCTAssertEqual(sut.translation, .init(dx: 10, dy: -20))
        XCTAssertEqual(sut.scale, .init(width: 30, height: 40))
        XCTAssertEqual(sut.rotation, .pi)

        XCTAssertEqual(
            sut.transform,
            .identity.translatedBy(x: 10, y: -20).scaledBy(x: 30, y: 40).rotated(by: .pi)
        )
    }

    func testTransformComponents_negativeRotation() {
        var sut = AnimatorTransientView.Properties(alpha: 0.5, transform: .identity)

        sut.translation = .init(dx: 10, dy: 20)
        sut.scale = .init(width: 30, height: 40)
        sut.rotation = -.pi

        XCTAssertEqual(sut.translation, .init(dx: 10, dy: 20))
        XCTAssertEqual(sut.scale, .init(width: 30, height: 40))
        XCTAssertEqual(sut.rotation, -.pi)

        XCTAssertEqual(
            sut.transform,
            .identity.translatedBy(x: 10, y: 20).scaledBy(x: 30, y: 40).rotated(by: -.pi)
        )
    }
}

extension AnimatorTransientViewTests {
    func testTransformComponents_negativeXNegativeY() {
        var sut = AnimatorTransientView.Properties(alpha: 0.5, transform: .identity)

        sut.translation = .init(dx: -10, dy: -20)
        sut.scale = .init(width: 30, height: 40)
        sut.rotation = .pi

        XCTAssertEqual(sut.translation, .init(dx: -10, dy: -20))
        XCTAssertEqual(sut.scale, .init(width: 30, height: 40))
        XCTAssertEqual(sut.rotation, .pi)

        XCTAssertEqual(
            sut.transform,
            .identity.translatedBy(x: -10, y: -20).scaledBy(x: 30, y: 40).rotated(by: .pi)
        )
    }

    func testTransformComponents_negativeXNegativeRotation() {
        var sut = AnimatorTransientView.Properties(alpha: 0.5, transform: .identity)

        sut.translation = .init(dx: -10, dy: 20)
        sut.scale = .init(width: 30, height: 40)
        sut.rotation = -.pi

        XCTAssertEqual(sut.translation, .init(dx: -10, dy: 20))
        XCTAssertEqual(sut.scale, .init(width: 30, height: 40))
        XCTAssertEqual(sut.rotation, -.pi)

        XCTAssertEqual(
            sut.transform,
            .identity.translatedBy(x: -10, y: 20).scaledBy(x: 30, y: 40).rotated(by: -.pi)
        )
    }

    func testTransformComponents_negativeYNegativeRotation() {
        var sut = AnimatorTransientView.Properties(alpha: 0.5, transform: .identity)

        sut.translation = .init(dx: 10, dy: -20)
        sut.scale = .init(width: 30, height: 40)
        sut.rotation = -.pi

        XCTAssertEqual(sut.translation, .init(dx: 10, dy: -20))
        XCTAssertEqual(sut.scale, .init(width: 30, height: 40))
        XCTAssertEqual(sut.rotation, -.pi)

        XCTAssertEqual(
            sut.transform,
            .identity.translatedBy(x: 10, y: -20).scaledBy(x: 30, y: 40).rotated(by: -.pi)
        )
    }
}

extension AnimatorTransientViewTests {
    func testTransformComponents_negativeXNegativeYNegativeRotation() {
        var sut = AnimatorTransientView.Properties(alpha: 0.5, transform: .identity)

        sut.translation = .init(dx: -10, dy: -20)
        sut.scale = .init(width: 30, height: 40)
        sut.rotation = -.pi

        XCTAssertEqual(sut.translation, .init(dx: -10, dy: -20))
        XCTAssertEqual(sut.scale, .init(width: 30, height: 40))
        XCTAssertEqual(sut.rotation, -.pi)

        XCTAssertEqual(
            sut.transform,
            .identity.translatedBy(x: -10, y: -20).scaledBy(x: 30, y: 40).rotated(by: -.pi)
        )
    }
}

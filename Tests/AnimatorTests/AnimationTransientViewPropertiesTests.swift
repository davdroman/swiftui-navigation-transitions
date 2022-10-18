@_spi(package) @testable import Animator
import UIKit
import XCTest

final class AnimationTransientViewPropertiesTests: XCTestCase {}

extension AnimationTransientViewPropertiesTests {
    func testInitAndSet() {
        var sut = AnimationTransientView.Properties(alpha: 0.5, transform: .identity)
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

extension AnimationTransientViewPropertiesTests {
    func testTransformComponents() {
        var sut = AnimationTransientView.Properties(alpha: 0.5, transform: .identity)

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

extension AnimationTransientViewTests {
    func testTransformComponents_negativeX() {
        var sut = AnimationTransientView.Properties(alpha: 0.5, transform: .identity)

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
        var sut = AnimationTransientView.Properties(alpha: 0.5, transform: .identity)

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
        var sut = AnimationTransientView.Properties(alpha: 0.5, transform: .identity)

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

extension AnimationTransientViewTests {
    func testTransformComponents_negativeXNegativeY() {
        var sut = AnimationTransientView.Properties(alpha: 0.5, transform: .identity)

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
        var sut = AnimationTransientView.Properties(alpha: 0.5, transform: .identity)

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
        var sut = AnimationTransientView.Properties(alpha: 0.5, transform: .identity)

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

extension AnimationTransientViewTests {
    func testTransformComponents_negativeXNegativeYNegativeRotation() {
        var sut = AnimationTransientView.Properties(alpha: 0.5, transform: .identity)

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

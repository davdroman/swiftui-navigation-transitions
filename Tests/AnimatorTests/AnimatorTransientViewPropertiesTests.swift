@_spi(package) @testable import Animator
import TestUtils

final class AnimatorTransientViewPropertiesTests: XCTestCase {
    var sut = AnimatorTransientView.Properties(
        alpha: 0.5,
        layer: .init(
            transform: CATransform3DIdentity,
            zPosition: 0
        ),
        transform: .identity
    )
}

extension AnimatorTransientViewPropertiesTests {
    func testInitAndSet() {
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

extension AnimatorTransientViewPropertiesTests {
    func testTransformComponents_negativeX() {
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

extension AnimatorTransientViewPropertiesTests {
    func testTransformComponents_negativeXNegativeY() {
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

extension AnimatorTransientViewPropertiesTests {
    func testTransformComponents_negativeXNegativeYNegativeRotation() {
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

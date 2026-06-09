import UIKit

extension Animation {
	@MainActor
	public static func easeOut(duration: Double) -> Self {
		.init(duration: duration, curve: .easeOut)
	}

	@MainActor
	public static var easeOut: Self {
		.easeOut(duration: defaultDuration)
	}
}

import UIKit

extension Animation {
	@MainActor
	public static func easeInOut(duration: Double) -> Self {
		.init(duration: duration, curve: .easeInOut)
	}

	@MainActor
	public static var easeInOut: Self {
		.easeInOut(duration: defaultDuration)
	}
}

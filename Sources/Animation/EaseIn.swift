import UIKit

extension Animation {
	@MainActor
	public static func easeIn(duration: Double) -> Self {
		.init(duration: duration, curve: .easeIn)
	}

	@MainActor
	public static var easeIn: Self {
		.easeIn(duration: defaultDuration)
	}
}

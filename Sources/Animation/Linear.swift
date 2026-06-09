import UIKit

extension Animation {
	@MainActor
	public static func linear(duration: Double) -> Self {
		.init(duration: duration, curve: .linear)
	}

	@MainActor
	public static var linear: Self {
		.linear(duration: defaultDuration)
	}
}

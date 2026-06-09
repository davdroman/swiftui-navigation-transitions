import UIKit

extension Animation {
	@MainActor
	public static var `default`: Self {
		.init(duration: defaultDuration, curve: .easeInOut)
	}
}

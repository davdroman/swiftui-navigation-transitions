import XCTest

/// Skips a test that needs a window where tests can't create one: Mac Catalyst test bundles run without a host app.
func skipUnlessWindowsAreAvailable() throws {
	#if targetEnvironment(macCatalyst)
	throw XCTSkip("Mac Catalyst can't create windows without a host app")
	#endif
}

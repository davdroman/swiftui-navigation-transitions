import SwiftUI

struct AppView: View {
	@ObservedObject var appState = AppState()

	var body: some View {
		RootView().environmentObject(appState)
	}
}

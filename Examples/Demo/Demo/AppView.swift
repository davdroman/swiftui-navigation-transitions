import SwiftUI

struct AppView: View {
	@StateObject var appState = AppState()

	var body: some View {
		RootView().environmentObject(appState)
	}
}

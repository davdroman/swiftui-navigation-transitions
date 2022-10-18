import NavigationTransitions
import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if #available(iOS 16, *) {
                NavigationStack {
                    PageOne()
                }
            } else {
                NavigationView {
                    PageOne()
                }
                .navigationViewStyle(.stack)
            }
        }
        .navigationViewStackTransition(
            appState.transition().animation(appState.animation()),
            interactivity: appState.interactivity()
        )
        .sheet(isPresented: $appState.isPresentingSettings, content: SettingsView.init)
    }
}

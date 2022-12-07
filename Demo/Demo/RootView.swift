import NavigationTransitions
import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if #available(iOS 16, tvOS 16, *) {
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
        .navigationTransition(transition.animation(animation), interactivity: interactivity)
        .sheet(isPresented: $appState.isPresentingSettings) {
            SettingsView().environmentObject(appState)
        }
    }

    var transition: AnyNavigationTransition {
        appState.transition()
    }

    var animation: AnyNavigationTransition.Animation? {
        appState.animation(
            duration: appState.duration,
            stiffness: appState.stiffness,
            damping: appState.damping
        )
    }

    var interactivity: AnyNavigationTransition.Interactivity {
        appState.interactivity()
    }
}

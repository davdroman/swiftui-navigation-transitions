import SwiftUI
import SwiftUINavigationTransitions

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
		.customNavigationTransition(transition.animation(animation), interactivity: interactivity)
		.sheet(isPresented: $appState.isPresentingSettings) {
			SettingsView().environmentObject(appState)
		}
	}

	var transition: CustomNavigationTransition {
		appState.transition()
	}

	var animation: CustomNavigationTransition.Animation? {
		appState.animation(
			duration: appState.duration,
			stiffness: appState.stiffness,
			damping: appState.damping,
		)
	}

	var interactivity: CustomNavigationTransition.Interactivity {
		appState.interactivity()
	}
}

import SwiftUI
import SwiftUINavigationTransitions

struct RootView: View {
	@EnvironmentObject var appState: AppState

	@State private var interactiveProgress: CGFloat = 0.0
	@State private var lastInteractiveResult: String = "—"

	var body: some View {
		ZStack(alignment: .bottom) {
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
			.navigationTransition(
				transition.animation(animation),
				interactivity: interactivity,
				onInteractiveProgress: { progress in
					// update UI on main thread
					Task { @MainActor in
						interactiveProgress = progress
					}
				},
				onInteractiveCompletion: { didPop in
					Task { @MainActor in
						lastInteractiveResult = didPop ? "Pop: success" : "Pop: cancelled"
					}
				}
			)

			// overlay at bottom showing progress and result
			VStack(spacing: 6) {
				HStack {
					Text("Progress: \(Int((interactiveProgress * 100).rounded()))%")
						.font(.subheadline).bold()
					Spacer()
				}
				HStack {
					Text(lastInteractiveResult)
						.font(.subheadline)
					Spacer()
				}
			}
			.padding()
			.background(.ultraThinMaterial)
			.cornerRadius(12)
			.padding([.horizontal, .bottom], 16)
		}
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
			damping: appState.damping,
		)
	}

	var interactivity: AnyNavigationTransition.Interactivity {
		appState.interactivity()
	}
}

import NavigationTransitions
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transition")) {
                    picker("Transition", $appState.transition)
                }

                Section(header: Text("Animation")) {
                    picker("Animation", $appState.animation)
                    switch appState.animation {
                    case .none:
                        EmptyView()
                    case .linear, .easeInOut:
                        picker("Duration", $appState.duration)
                    case .spring:
                        picker("Stiffness", $appState.stiffness)
                        picker("Damping", $appState.damping)
                    }
                }

                Section(header: Text("Interactivity"), footer: interactivityFooter) {
                    picker("Interactivity", $appState.interactivity)
                }
            }
            #if !os(tvOS)
            .navigationBarTitle("Settings", displayMode: .inline)
            #endif
            .navigationBarItems(
                leading: Button("Shuffle", action: shuffle),
                trailing: Button(action: dismiss) { Text("Done").bold() }
            )
        }
        .navigationViewStyle(.stack)
    }

    var interactivityFooter: some View {
        Text(
            """
            You can choose the swipe-back gesture to be:

            • Disabled.
            • Edge Pan: recognized from the edge of the screen only.
            • Pan: recognized anywhere on the screen! ✨
            """
        )
    }

    @ViewBuilder
    func picker<Selection: CaseIterable & Hashable & CustomStringConvertible>(
        _ label: String,
        _ selection: Binding<Selection>
    ) -> some View where Selection.AllCases: RandomAccessCollection {
        Picker(
            selection: selection,
            label: Text(label)
        ) {
            ForEach(Selection.allCases, id: \.self) {
                Text($0.description).tag($0)
            }
        }
    }

    func shuffle() {
        appState.transition = .allCases.randomElement()!

        appState.animation = .allCases.randomElement()!
        appState.duration = .allCases.randomElement()!
        appState.stiffness = .allCases.randomElement()!
        appState.damping = .allCases.randomElement()!

        appState.interactivity = .allCases.randomElement()!
    }

    func dismiss() {
        appState.isPresentingSettings = false
    }
}

struct SettingsViewPreview: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppState())
    }
}

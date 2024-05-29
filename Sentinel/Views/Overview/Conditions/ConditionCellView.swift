import SwiftUI

struct ConditionCellView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    let condition: Condition

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showArchiveConfirmation: Bool = false

    var body: some View {
        NavigationLink {
            ConditionDetailsView(condition: condition)
                .environmentObject(chatViewModel)
                .environmentObject(tabsViewModel)
                .navigationTitle(condition.name.capitalized)
                .navigationBarItems(trailing:
                    Button {
                        showArchiveConfirmation = true
                    } label: {
                        Text("Archive")
                    }
                )
        } label: {
            Image(systemName: "stethoscope")
                .symbolRenderingMode(.multicolor)
            Text(condition.name.capitalized)
        }
        .swipeActions(edge: .trailing) {
            Button {
                showArchiveConfirmation = true
            } label: {
                Label("Archive", systemImage: "archivebox")
            }
            .tint(.blue)
        }
        .alert("Error", isPresented: $showError) {
            Button("Ok") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog("Archive condition?", isPresented: $showArchiveConfirmation, actions: {
            Button("Yes") {
                showArchiveConfirmation = false
                Task {
                    do {
                        try await homeViewModel.archiveCondition(condition.id)
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }

            Button("No", role: .cancel) {
                showArchiveConfirmation = false
            }
        }) {
            Text("Archiving this condition will remove it from the list and let Sentinel know it's no longer relevant for you, but it will still be in your records. Are you sure you want to do this?")
        }
    }
}

// #Preview {
//    ConditionCellView()
// }

import SwiftUI

struct MedicationCellView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    let medication: Medication

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showArchiveConfirmation: Bool = false

    var body: some View {
        NavigationLink {
            MedicationDetailsView(medication: medication)
                .environmentObject(chatViewModel)
                .environmentObject(tabsViewModel)
                .navigationTitle(medication.name.capitalized)
                .navigationBarItems(trailing:
                    Button {
                        showArchiveConfirmation = true
                    } label: {
                        Text("Archive")
                    }
                )
        } label: {
            Image(systemName: "pills.fill")
                .symbolRenderingMode(.multicolor)
            Text(medication.name.capitalized)
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
        .confirmationDialog("Archive medication?", isPresented: $showArchiveConfirmation, actions: {
            Button("Yes") {
                showArchiveConfirmation = false
                Task {
                    do {
                        try await homeViewModel.archiveMedication(medication.id)
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
            Text("Archiving this medication will remove it from the list and let Sentinel know it's no longer relevant for you, but it will still be in your records. Are you sure you want to do this?")
        }
    }
}

// #Preview {
//    MedicationCellView()
// }

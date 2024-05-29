import SwiftUI

struct ProcedureCellView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    let procedure: Procedure

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showArchiveConfirmation: Bool = false

    var body: some View {
        NavigationLink {
            ProcedureDetailsView(procedure: procedure)
                .environmentObject(chatViewModel)
                .environmentObject(tabsViewModel)
                .navigationTitle(procedure.name)
                .navigationBarItems(trailing:
                    Button {
                        showArchiveConfirmation = true
                    } label: {
                        Text("Archive")
                    }
                )
        } label: {
            Image(systemName: "ivfluid.bag")
                .symbolRenderingMode(.multicolor)
            Text(procedure.name)
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
        .confirmationDialog("Archive procedure?", isPresented: $showArchiveConfirmation, actions: {
            Button("Yes") {
                showArchiveConfirmation = false
                Task {
                    do {
                        try await homeViewModel.archiveProcedure(procedure.id)
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
            Text("Archiving this procedure will remove it from the list and let Sentinel know it's no longer relevant for you, but it will still be in your records. Are you sure you want to do this?")
        }

    }
}

// #Preview {
//    ProcedureCellView()
// }

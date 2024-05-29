import SwiftUI

struct ProcedureDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ProcedureDetailsViewModel = ProcedureDetailsViewModel()
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    let procedure: Procedure

    @State private var errorMessage: String?
    @State private var showError: Bool = false

    var body: some View {
        List {
            Section {
                if let performedOn = procedure.performedOn {
                    VStack(alignment: .leading) {
                        Text("Performed On")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(dateString(isoStringToDate(performedOn) ?? Date(), style: .medium))
                    }
                }

                if let status = procedure.status {
                    VStack(alignment: .leading) {
                        Text("Status")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(status.capitalized)
                    }
                }

                if let source = procedure.source {
                    VStack(alignment: .leading) {
                        Text("Source")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(source)
                    }
                }

                Button {
                    chatViewModel.startConversationWithPrompt(chatPrompt: "I'd like to learn more about the \(procedure.name) procedure")
                    tabsViewModel.changeTab("chat")
                } label: {
                    Text("Discuss this procedure with Sentinel")
                }
            }

            if viewModel.relatedConversations.count > 0 {
                Section(header: SectionHeaderView(title: "Related Conversations")) {
                    ForEach(viewModel.relatedConversations) { conversation in
                        ConversationCellView(
                            conversation: conversation,
                            onTap: {
                                tabsViewModel.changeTab("chat")
                            },
                            onError: { error in
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                        )
                    }
                }
            }
        }
        .task {
            do {
                try await viewModel.fetchRelatedConversations(procedureId: procedure.id)
            } catch {
                AppLogger.instance("Networking").error("Failed to fetch related conversations: \(error.localizedDescription, privacy: .public)")
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("Ok") {
                showError = false
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "There was an error with your request. Please try again or contact support.")
        }
    }
}

// #Preview {
//    ProcedureDetailsView()
// }

import SwiftUI

struct MedicationDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: MedicationDetailsViewModel = MedicationDetailsViewModel()
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    let medication: Medication

    @State private var errorMessage: String?
    @State private var showError: Bool = false

    var body: some View {
        List {
            Section {
                if let dosageInstructions = medication.dosageInstructions {
                    VStack(alignment: .leading) {
                        Text("Dosage Instructions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(dosageInstructions)
                    }
                }

                if let authoredOn = medication.authoredOn {
                    VStack(alignment: .leading) {
                        Text("Prescribed On")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(dateString(isoStringToDate(authoredOn) ?? Date(), style: .medium))
                    }
                }

                if let authoredBy = medication.authoredBy {
                    VStack(alignment: .leading) {
                        Text("Prescribed By")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(authoredBy)
                    }
                }

                if let source = medication.source {
                    VStack(alignment: .leading) {
                        Text("Source")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(source)
                    }
                }

                Button {
                    chatViewModel.startConversationWithPrompt(chatPrompt: "I'd like to learn more about the \(medication.name) medication")
                    tabsViewModel.changeTab("chat")
                } label: {
                    Text("Discuss this medication with Sentinel")
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
                try await viewModel.fetchRelatedConversations(medicationId: medication.id)
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
//    MedicationDetailsView()
// }

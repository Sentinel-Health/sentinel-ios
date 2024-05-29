import SwiftUI

struct AllergyDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: AllergyDetailsViewModel = AllergyDetailsViewModel()
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    let allergy: Allergy

    @State private var errorMessage: String?
    @State private var showError: Bool = false

    var body: some View {
        List {
            Section {
                if let recordedOn = allergy.recordedOn {
                    VStack(alignment: .leading) {
                        Text("Recorded On")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(dateString(isoStringToDate(recordedOn) ?? Date(), style: .medium))
                    }
                }

                if let source = allergy.source {
                    VStack(alignment: .leading) {
                        Text("Source")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(source)
                    }
                }

                Button {
                    chatViewModel.startConversationWithPrompt(chatPrompt: "I'd like to learn more about my \(allergy.name) allergy")
                } label: {
                    Text("Discuss this allergy with Sentinel")
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
                try await viewModel.fetchRelatedConversations(allergyId: allergy.id)
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
//    AllergyDetailsView()
// }

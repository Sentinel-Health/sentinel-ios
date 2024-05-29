import SwiftUI

struct ConditionDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ConditionDetailsViewModel = ConditionDetailsViewModel()
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    let condition: Condition

    @State private var errorMessage: String?
    @State private var showError: Bool = false

    var body: some View {
        List {
            Section {
                Button {
                    tabsViewModel.changeTab("chat")
                    chatViewModel.startConversationWithPrompt(chatPrompt: "I'd like to learn more about my \(condition.name) condition")
                } label: {
                    Text("Discuss this condition with Sentinel")
                        .foregroundStyle(.blue)
                }
            }

            if let conditionHistory = condition.history {
                Section(header: SectionHeaderView(title: "History")) {
                    ForEach(conditionHistory) { history in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                if let recordedOn = history.recordedOn {
                                    VStack(alignment: .leading) {
                                        Text("Recorded On")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(dateString(isoStringToDate(recordedOn) ?? Date(), style: .medium))
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Status")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(history.status.capitalized)
                                }
                            }

                            if let source = history.source {
                                VStack(alignment: .leading) {
                                    Text("Source")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(source)
                                }
                            }
                        }
                    }
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
                try await viewModel.fetchRelatedConversations(conditionId: condition.id)
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
//    ConditionDetailsView()
// }

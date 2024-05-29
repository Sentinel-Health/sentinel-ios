import SwiftUI

struct ConversationsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ConversationsViewModel = ConversationsViewModel()
    @ObservedObject var chatViewModel: ChatViewModel

    @Binding var showingModal: Bool

    @State private var searchText = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var showFetchError: Bool = false
    @State private var errorMessage: String = ""

    var conversationsWithMessages: [Conversation] {
        viewModel.conversations.filter { !$0.messages.isEmpty }
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        if isLoading {
                            VStack {
                                ProgressView().id(UUID())
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .listRowSeparator(.hidden)
                            .listRowBackground(EmptyView())
                        } else if showFetchError {
                            VStack {
                                Text("There was an error fetching your conversations. Please try again or contact support.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                Button("Try Again") {
                                    Task {
                                        await fetchConversations()
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity)
                        } else if !searchText.isEmpty && conversationsWithMessages.isEmpty {
                            VStack {
                                Text("No conversations found for:")
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                Text("\"\(searchText)\"")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                            .listRowBackground(EmptyView())
                        } else {
                            ForEach(conversationsWithMessages) { conversation in
                                ConversationCellView(
                                    conversation: conversation,
                                    onTap: {
                                        showingModal = false
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
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search conversations")
                .onChange(of: searchText) {
                    if searchText.isEmpty {
                        Task {
                            await fetchConversations()
                        }
                    }
                }
                .onSubmit(of: .search) {
                    Task {
                        await fetchConversations(searchText: searchText)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("Ok") {
                    showError = false
                    errorMessage = ""
                }
            } message: {
                Text(errorMessage)
            }
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                    showingModal = false
                }
            ) {
                Image(systemName: "multiply")
            }
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.secondary)
            )
            .task {
                await fetchConversations()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationContentInteraction(.scrolls)
    }

    func fetchConversations(searchText: String? = nil) async {
        do {
            showFetchError = false
            isLoading = true
            try await viewModel.fetchConversations(searchText: searchText)
            isLoading = false
        } catch {
            isLoading = false
            showFetchError = true
        }
    }
}

// #Preview {
//    ConversationsView()
// }

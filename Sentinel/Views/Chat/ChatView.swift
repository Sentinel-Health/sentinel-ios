import SwiftUI
import AlertToast

struct ChatView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var viewModel: ChatViewModel

    @State var showingConversationsHistoryModal = false
    @State var isInitialLoad: Bool = true

    var body: some View {
        NavigationStack {
            ConversationMessagesView()
                .environmentObject(rootViewModel)
                .environmentObject(viewModel)
                .navigationTitle("")
                .navigationBarItems(
                    leading:
                        HStack(spacing: 16) {
                            Button(action: {
                                showingConversationsHistoryModal = true
                            }, label: {
                                Image(systemName: "bubble.left.and.bubble.right")
                            })
                            .tint(colorScheme == .dark ? .white : .black)
                        },
                    trailing:
                        Button(action: {
                            Task {
                                do {
                                    try await viewModel.startNewConversation()
                                } catch {
                                    viewModel.errorMessage = error.localizedDescription
                                    viewModel.showError = true
                                }
                            }
                        }, label: {
                            Image(systemName: "plus.bubble")
                        })
                        .tint(colorScheme == .dark ? .white : .black)
                        .disabled(viewModel.currentConversation?.messages.count == 0)
                )
                .onReceive(AppState.shared.$updatedChatSuggestions) { hasUpdated in
                    if hasUpdated {
                        Task {
                            await fetchChatSuggestions()
                            AppState.shared.updatedChatSuggestions = false
                        }
                    }
                }
                .sheet(isPresented: $rootViewModel.showSentinelOnboarding) {
                    SentinelOnboardingView()
                        .environmentObject(rootViewModel)
                        .environmentObject(viewModel)
                }
                .alert("Error", isPresented: $viewModel.showError) {
                    Button("Ok") {
                        viewModel.showError = false
                        viewModel.errorMessage = ""
                    }
                } message: {
                    Text(viewModel.errorMessage)
                }
                .sheet(isPresented: $showingConversationsHistoryModal) {
                    ConversationsView(
                        chatViewModel: viewModel,
                        showingModal: $showingConversationsHistoryModal
                    )
                }
                .toast(isPresenting: $viewModel.showFeedbackToast) {
                    AlertToast(
                        displayMode: .alert,
                        type: .regular,
                        title: "Thanks for the feedback!"
                    )
                }
        }
        .task {
            if isInitialLoad {
                viewModel.isLoading = true
            }
            do {
                if viewModel.localMessages.isEmpty || viewModel.currentConversation != nil {
                    try await viewModel.fetchConversation()
                }
            } catch {
                viewModel.isLoading = false
                viewModel.errorMessage = error.localizedDescription
                viewModel.showError = true
            }
            if isInitialLoad {
                viewModel.isLoading = false
                isInitialLoad = false
            }
            await fetchChatSuggestions()
        }
        .tint(colorScheme == .dark ? .white : .black)
        .onReceive(AppState.shared.$conversationNotificationOpenedId) { conversationId in
            if let conversationId = conversationId {
                Task {
                    do {
                        try await viewModel.selectConversation(conversationId: conversationId)
                        AppState.shared.conversationNotificationOpenedId = nil
                    } catch {
                        viewModel.errorMessage = error.localizedDescription
                        viewModel.showError = true
                    }
                }
            }
        }
    }

    func fetchChatSuggestions() async {
        do {
            try await viewModel.fetchChatSuggestions()
        } catch {
            // Fail silently
            AppLogger.instance().error("Error: \(error.localizedDescription)")
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// #Preview {
//    ChatView()
// }

import SwiftUI

struct ConversationMessagesView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var viewModel: ChatViewModel

    @State private var keyboardHeight: CGFloat = 0
    @State var showingConversationsHistoryModal = false

    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)

    private func dismissKeyboard() {
        UIApplication.shared
            .sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack {
                            Spacer()
                            if viewModel.isLoading {
                                VStack {
                                    ProgressView()
                                }
                                .padding()
                                .frame(width: geometry.size.width)
                                .frame(minHeight: geometry.size.height)
                            } else {
                                if viewModel.localMessages.count > 0 {
                                    VStack(alignment: .leading, spacing: 16) {
                                        let filteredMessages = filteredAndTransformedMessages(from: viewModel.localMessages)

                                        ForEach(filteredMessages.indices.reversed(), id: \.self) { index in
                                            filteredMessages[index].id(index == 0 ? "lastMessage" : nil)
                                        }
                                        if viewModel.isAssistantResponding {
                                            ChatMessageView(
                                                message: Message(role: "assistant", content: ""),
                                                isLoading: true
                                            )
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .frame(width: geometry.size.width)
                                    .frame(minHeight: geometry.size.height)
                                    .onAppear {
                                        withAnimation {
                                            scrollProxy.scrollTo("lastMessage", anchor: .bottom)
                                        }
                                    }
                                } else {
                                    EmptyChatView()
                                        .environmentObject(rootViewModel)
                                        .environmentObject(viewModel)
                                        .padding(.vertical)
                                        .frame(width: geometry.size.width)
                                        .frame(minHeight: geometry.size.height)
                                }
                            }
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onTapGesture {
                        dismissKeyboard()
                    }
                    .onAppear {
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                            let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                            let height = value.height
                            self.keyboardHeight = height
                        }

                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                            self.keyboardHeight = 0
                        }
                    }
                    .onDisappear {
                        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
                        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
                    }
                    .onChange(of: viewModel.localMessages) {
                        withAnimation {
                            scrollProxy.scrollTo("lastMessage", anchor: .top)
                        }
                    }
                    .onChange(of: viewModel.currentConversation?.id) {
                        dismissKeyboard()
                        Task {
                            do {
                                try await viewModel.fetchChatSuggestions()
                            } catch {
                                // Fail silently
                                AppLogger.instance().error("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            MessageBarView()
                .padding(.horizontal)
                .padding(.top, 0)
                .padding(.bottom, 8)
                .environmentObject(viewModel)
        }
        .onReceive(viewModel.$currentConversation) { currentConversation in
            DispatchQueue.main.async {
                if let serverMessages = currentConversation?.messages {
                    if viewModel.localMessages != serverMessages {
                        impactFeedbackgenerator.impactOccurred()
                    }
                    viewModel.localMessages = serverMessages
                }
            }
        }
    }

    func filteredAndTransformedMessages(from messages: [Message]) -> [AnyView] {
        var skipNext = false
        var result: [AnyView] = []

        for message in messages {
            if skipNext {
                skipNext = false
            } else if let _ = message.functionCall {
                // Not showing non-chat messages for now
                // result.append(AnyView(ChatFunctionCallView(message: message)))
            } else if let _ = message.toolCalls {
                // Not showing non-chat messages for now
            } else if message.role == "function" {
                skipNext = true
                // result.append(AnyView(ChatFunctionCallView(message: message, isLoading: false)))
            } else if message.role == "tool" {
                skipNext = true
                // Not showing these for now
            } else {
                result.append(AnyView(ChatMessageView(message: message)))
            }
        }

        return result
    }
}

// #Preview {
//    ConversationMessagesView()
// }

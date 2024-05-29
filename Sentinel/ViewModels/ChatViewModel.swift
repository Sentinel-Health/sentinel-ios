import Foundation
import AlertToast
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var currentConversation: Conversation?
    @Published var isAssistantResponding: Bool = false
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var localMessages: [Message] = []
    @Published var chatSuggestions: [ChatSuggestion] = []
    @Published var newConversationOptions: [AnyHashable: Any] = [:]
    @Published var showFeedbackToast: Bool = false

    public func startConversationWithPrompt(chatPrompt: String) {
        resetConversationState()
        localMessages = []
        _ = addNewLocalMessage(message: chatPrompt)
        Task {
            do {
                try await startNewConversation(initialMessage: chatPrompt)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    public func resetConversationState() {
        currentConversation = nil
        localMessages = []
        isLoading = false
        isAssistantResponding = false
        showError = false
        errorMessage = ""
    }

    public func resetNewConversationData() {
        newConversationOptions = [:]
    }

    public func addNewLocalMessage(message: String) -> Message {
        let newMessage = Message(
            role: "user",
            content: message
        )
        localMessages.insert(newMessage, at: 0)
        return newMessage
    }

    public func fetchConversation() async throws {
        var url: String

        if let conversationId = currentConversation?.id {
            url = "/conversations/\(conversationId)"
        } else {
            url = "/conversations/latest"
        }

        let data = try await apiCall(urlPath: url, method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(Conversation.self, from: data) {
            DispatchQueue.main.async {
                self.currentConversation = decodedResponse
            }
        }
    }

    public func startNewConversation(initialMessage: String? = nil) async throws {
        var messageData: [String: Any]? = [:]
        if let message = initialMessage {
            messageData = [
                "message": message
            ]
            DispatchQueue.main.async {
                self.isAssistantResponding = true
            }
        }

        do {
            let data = try await apiCall(urlPath: "/conversations", method: "POST", requestData: messageData)
            if initialMessage != nil {
                DispatchQueue.main.async {
                    self.isAssistantResponding = false
                }
            }
            if let decodedResponse = try? JSONDecoder().decode(Conversation.self, from: data) {
                DispatchQueue.main.async {
                    self.currentConversation = decodedResponse
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isAssistantResponding = false
            }
            throw error
        }
    }

    public func startOnboardingConversation() async throws {
        let data = try await apiCall(urlPath: "/onboarding/conversations", method: "POST", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(Conversation.self, from: data) {
            DispatchQueue.main.async {
                self.currentConversation = decodedResponse
            }
        }
    }

    public func getOnboardingConversation() async throws {
        let data = try await apiCall(urlPath: "/onboarding/conversation", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(Conversation.self, from: data) {
            DispatchQueue.main.async {
                self.currentConversation = decodedResponse
            }
        }
    }

    public func selectConversation(conversationId: String) async throws {
        let data = try await apiCall(urlPath: "/conversations/\(conversationId)", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(Conversation.self, from: data) {
            DispatchQueue.main.async {
                self.currentConversation = decodedResponse
            }
        }
    }

    public func sendMessageToServer(message: Message) async throws {
        guard let conversationId = self.currentConversation?.id else {
            return
        }

        let messageJsonData = serializeMessageDataForRequest(message: message)
        let messageData: [String: Any] = [
            "conversationId": conversationId,
            "message": messageJsonData
        ]

        DispatchQueue.main.async {
            self.isAssistantResponding = true
        }

        do {
            let data = try await apiCall(urlPath: "/conversations/\(conversationId)/messages", method: "POST", requestData: messageData)
            DispatchQueue.main.async {
                self.isAssistantResponding = false
            }

            if (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) != nil {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let newMessagesResponse = try? decoder.decode(NewMessagesResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.currentConversation?.messages.insert(message, at: 0)
                        self.currentConversation?.messages.insert(contentsOf: newMessagesResponse.newMessages, at: 0)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isAssistantResponding = false
            }
            throw error
        }
    }

    public func fetchChatSuggestions() async throws {
        let data = try await apiCall(urlPath: "/chat_suggestions", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(ChatSuggestionsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.chatSuggestions = decodedResponse.suggestions
            }
        }
    }

    public func markChatSuggestionUsed(_ chatSuggestionId: String) {
        Task {
            do {
                _ = try await apiCall(urlPath: "/chat_suggestions/\(chatSuggestionId)/used", requestData: nil)
            } catch {
                AppLogger.instance("Networking").error("failed to update chat suggestion")
            }
        }
    }
}

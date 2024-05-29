import Foundation

class ConversationsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var conversations: [Conversation] = []

    public func fetchConversations(searchText: String? = nil) async throws {
        var urlPath: String
        if let searchText = searchText {
            urlPath = "/conversations?query=\(searchText)"
        } else {
            urlPath = "/conversations"
        }
        let data = try await apiCall(urlPath: urlPath, method: "GET", requestData: nil)

        if let decodedResponse = try? JSONDecoder().decode([Conversation].self, from: data) {
            DispatchQueue.main.async {
                self.conversations = decodedResponse
            }
        }
    }
}

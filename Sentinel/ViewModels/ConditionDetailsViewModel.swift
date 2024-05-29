import Foundation

class ConditionDetailsViewModel: ObservableObject {
    @Published var relatedConversations: [Conversation] = []

    public func fetchRelatedConversations(conditionId: String) async throws {
        let data = try await apiCall(urlPath: "/conditions/\(conditionId)/related_conversations", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode([Conversation].self, from: data) {
            DispatchQueue.main.async {
                self.relatedConversations = decodedResponse
            }
        }
    }
}

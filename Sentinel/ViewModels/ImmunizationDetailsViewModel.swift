import Foundation

class ImmunizationDetailsViewModel: ObservableObject {
    @Published var relatedConversations: [Conversation] = []

    public func fetchRelatedConversations(immunizationId: String) async throws {
        let data = try await apiCall(urlPath: "/immunizations/\(immunizationId)/related_conversations", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode([Conversation].self, from: data) {
            DispatchQueue.main.async {
                self.relatedConversations = decodedResponse
            }
        }
    }
}

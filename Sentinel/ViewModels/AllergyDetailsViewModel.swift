import Foundation

class AllergyDetailsViewModel: ObservableObject {
    @Published var relatedConversations: [Conversation] = []

    public func fetchRelatedConversations(allergyId: String) async throws {
        let data = try await apiCall(urlPath: "/allergies/\(allergyId)/related_conversations", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode([Conversation].self, from: data) {
            DispatchQueue.main.async {
                self.relatedConversations = decodedResponse
            }
        }
    }
}

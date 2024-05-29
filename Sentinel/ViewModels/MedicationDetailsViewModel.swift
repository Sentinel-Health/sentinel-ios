import Foundation

class MedicationDetailsViewModel: ObservableObject {
    @Published var relatedConversations: [Conversation] = []

    public func fetchRelatedConversations(medicationId: String) async throws {
        let data = try await apiCall(urlPath: "/medications/\(medicationId)/related_conversations", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode([Conversation].self, from: data) {
            DispatchQueue.main.async {
                self.relatedConversations = decodedResponse
            }
        }
    }
}

import Foundation

class ProcedureDetailsViewModel: ObservableObject {
    @Published var relatedConversations: [Conversation] = []

    public func fetchRelatedConversations(procedureId: String) async throws {
        let data = try await apiCall(urlPath: "/procedures/\(procedureId)/related_conversations", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode([Conversation].self, from: data) {
            DispatchQueue.main.async {
                self.relatedConversations = decodedResponse
            }
        }
    }
}

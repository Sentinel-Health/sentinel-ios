import Foundation

struct Conversation: Codable, Identifiable, Equatable {
    var id: String
    var messages: [Message]
    var createdAt: String?
    var updatedAt: String?
    var lastActivityAt: String?
    var title: String?
}

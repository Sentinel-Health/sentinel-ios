import Foundation

struct Message: Codable, Identifiable, Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    var id: String?
    var role: String
    var content: String?
    var name: String?
    var functionCall: FunctionCall?
    var toolCalls: [ToolCall]?
    var toolCallId: String?
    var createdAt: String?
    var updatedAt: String?
}

struct FunctionCall: Codable {
    var name: String
    var arguments: String
}

struct ToolCall: Codable {
    var id: String
    var type: String
    var function: FunctionCall?
}

struct NewMessagesResponse: Decodable {
    let newMessages: [Message]
}

import Foundation

struct ChatSuggestionsResponse: Codable {
    var suggestions: [ChatSuggestion]
}

struct ChatSuggestion: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var prompt: String
}

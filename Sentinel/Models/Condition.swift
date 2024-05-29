import Foundation

struct Condition: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var status: String
    var createdAt: String
    var updatedAt: String
    var history: [ConditionHistory]?
}

struct ConditionHistory: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var status: String
    var source: String?
    var recordedOn: String?
    var recordedBy: String?
    var createdAt: String
    var updatedAt: String
}

extension Condition {
    func mostRecentHistory() -> ConditionHistory? {
        // First, ensure history is not nil and not empty
        guard let sortedHistory = history, !sortedHistory.isEmpty else { return nil }

        // Sort the history by recordedOn in descending order and return the first element
        // Assuming recordedOn is always available; otherwise, use createdAt or another field as needed
        return sortedHistory.sorted(by: { $0.recordedOn ?? "" > $1.recordedOn ?? "" }).first
    }
}

import Foundation

struct Medication: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var status: String
    var source: String?
    var dosageInstructions: String?
    var authoredOn: String?
    var authoredBy: String?
    var createdAt: String
    var updatedAt: String
}

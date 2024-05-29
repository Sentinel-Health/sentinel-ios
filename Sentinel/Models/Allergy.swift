import Foundation

struct Allergy: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var status: String
    var source: String?
    var recordedOn: String?
    var createdAt: String
    var updatedAt: String
}

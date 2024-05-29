import Foundation

struct Procedure: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var source: String?
    var status: String?
    var performedOn: String?
    var createdAt: String
    var updatedAt: String
}

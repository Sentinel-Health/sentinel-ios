import Foundation

struct Immunization: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var source: String?
    var receivedOn: String?
    var createdAt: String
    var updatedAt: String
}

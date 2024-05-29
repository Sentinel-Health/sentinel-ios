import Foundation

struct HealthProfile: Codable, Identifiable {
    var id: String
    var legalFirstName: String?
    var legalLastName: String?
    var dob: String?
    var sex: String?
    var bloodType: String?
    var skinType: String?
    var wheelchairUse: String?
}

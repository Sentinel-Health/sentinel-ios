import Foundation

enum LabOrderRequirements: String, CaseIterable, Identifiable {
    case healthProfile = "health_profile"
    case address = "address"
    case phoneNumber = "phone_number"
    case hipaaAuthorization = "hipaa_authorization"
    case telehealthConsent = "telehealth_consent"

    var id: String { self.rawValue }
}

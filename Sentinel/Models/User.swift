import Foundation

struct User: Codable, Identifiable {
    var id: String
    var email: String
    var fullName: String?
    var firstName: String?
    var lastName: String?
    var picture: String?
    var phoneNumber: String?
    var phoneNumberVerified: Bool?
    var addressLine1: String?
    var addressLine2: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var country: String?
    var addressString: String?
    var hasCompletedOnboarding: Bool
    var isSyncingHealthData: Bool
    var dataSyncCompletedAt: String?
    var labTestOrdersCount: Int?
    var notificationSettings: NotificationSettings
}

struct NotificationSettings: Codable {
    var enabledPushNotifications: Bool
    var enabledEmailNotifications: Bool
    var dailyCheckin: Bool
    var dailyCheckinTime: String
}

import Foundation

struct UserNotificationsResponse: Codable {
    var notifications: [UserNotification]
}

struct UserNotification: Codable, Identifiable {
    var id: String
    var title: String?
    var body: String
    var notificationType: String?
    var read: Bool
    var createdAt: String
    var additionalData: UserNotificationAdditionalData?
}

struct UserNotificationAdditionalData: Codable {
    var conversation_id: String?
    var notification_message: String?
    var chat_prompt: String?
}

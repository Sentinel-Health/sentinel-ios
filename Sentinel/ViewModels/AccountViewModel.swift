import Foundation

class AccountViewModel: ObservableObject {
    func updateUserNotificationSettings(notificationSettings: [String: Any]?) async throws {
        _ = try await apiCall(urlPath: "/users/notifications/settings", requestData: notificationSettings)
    }
}

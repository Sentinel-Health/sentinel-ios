import Foundation

class NotificationsViewModel: ObservableObject {
    @Published var notifications: [UserNotification] = []

    public func fetchNotifications() async throws {
        let data = try await apiCall(urlPath: "/users/notifications", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(UserNotificationsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.notifications = decodedResponse.notifications
            }
        }
    }

    public func markNotificationRead(notificationId: String) async throws {
        let data = try await apiCall(urlPath: "/users/notifications/\(notificationId)/read", method: "POST", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(UserNotificationsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.notifications = decodedResponse.notifications
            }
        }
    }
}

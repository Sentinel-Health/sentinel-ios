import Foundation
import SwiftUI
import UserNotifications
import Combine

final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var showSettingsPage = false
    @Published var badgeNumber = 0

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPushNotificationAuthorization() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [
                .alert,
                .sound,
                .badge,
                .provisional,
                .providesAppNotificationSettings
            ])

        } catch {
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        showSettingsPage = true
    }
}

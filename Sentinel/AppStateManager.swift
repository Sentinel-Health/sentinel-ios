import Foundation
import Combine
import HealthKit
import SwiftUI

enum NotificationType: String {
    case newMessage = "new_message"
    case newCheckIn = "new_check_in"
    case newLabResults = "new_lab_results"
    case updatedHealthSuggestions = "updated_health_suggestions"
    case updatedChatSuggestions = "updated_chat_suggestions"
    case labTestOrderUpdate = "lab_test_order_update"
    case completedDataSync = "completed_data_sync"
}

class AppState: ObservableObject {
    static let shared = AppState()

    private(set) var isInBackground = false

    private var cancellables = Set<AnyCancellable>()

    @Published var hasAuthorizedHealthKit = false
    @Published var hasAuthorizedHealthRecords = false
    @Published var hasEnabledPushNotifications = false
    @Published var isSyncingAllHealthData = false
    @Published var isSyncingHealthDataInBackground = false

    @Published var notificationAlert: NotificationAlert?
    @Published var conversationNotificationOpenedId: String?
    @Published var updatedHealthSuggestions: Bool = false
    @Published var updatedChatSuggestions: Bool = false
    @Published var labTestOrderNotificationOpened: Bool = false

    private var hasSetupHealthKitBackgroundDelivery = false
    private var hasSetupHealthRecordsBackgroundDelivery = false

    private init() {
        isSyncingAllHealthData = UserDefaults.standard.bool(forKey: IS_SYNCING_ALL_HEALTH_DATA)
        isSyncingHealthDataInBackground = UserDefaults.standard.bool(forKey: IS_SYNCING_HEALTH_DATA_IN_BACKGROUND)
        hasAuthorizedHealthKit = UserDefaults.standard.bool(forKey: HAS_AUTHORIZED_HEALTH_KIT_KEY)
        hasAuthorizedHealthRecords = UserDefaults.standard.bool(forKey: HAS_AUTHORIZED_HEALTH_RECORDS_KEY)
        hasEnabledPushNotifications = UserDefaults.standard.bool(forKey: HAS_ENABLED_PUSH_NOTIFICATIONS_KEY)
        hasSetupHealthKitBackgroundDelivery = UserDefaults.standard.bool(forKey: HAS_SETUP_HEALTH_KIT_BACKGROUND_DELIVERY)
        hasSetupHealthRecordsBackgroundDelivery = UserDefaults.standard.bool(forKey: HAS_SETUP_HEALTH_RECORDS_BACKGROUND_DELIVERY)

        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceTokenNotification(_:)), name: .didReceiveDeviceToken, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc private func appMovedToBackground() {
        isInBackground = true
    }

    @objc private func appBecameActive() {
        isInBackground = false
    }

    func authorizedHealthRecords() async {
        UserDefaults.standard.set(true, forKey: HAS_AUTHORIZED_HEALTH_RECORDS_KEY)
        await HealthKitService.shared.setupHealthRecordsBackgroundDelivery()
        UserDefaults.standard.set(true, forKey: HAS_SETUP_HEALTH_RECORDS_BACKGROUND_DELIVERY)

        DispatchQueue.main.async {
            self.hasAuthorizedHealthRecords = true
            self.hasSetupHealthRecordsBackgroundDelivery = true
        }
    }

    func authorizedHealthKit() async {
        UserDefaults.standard.set(true, forKey: HAS_AUTHORIZED_HEALTH_KIT_KEY)
        await HealthKitService.shared.setupHealthKitBackgroundDelivery()
        UserDefaults.standard.set(true, forKey: HAS_SETUP_HEALTH_KIT_BACKGROUND_DELIVERY)

        DispatchQueue.main.async {
            self.hasAuthorizedHealthKit = true
            self.hasSetupHealthKitBackgroundDelivery = true
        }
    }

    func setQueryAnchor(anchor: HKQueryAnchor?, forKey: String) {
        if let anchor = anchor {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
            if let data = data {
                UserDefaults.standard.set(data, forKey: forKey)
            }
        }
    }

    func getQueryAnchor(forKey: String) -> HKQueryAnchor? {
        if let data = UserDefaults.standard.data(forKey: forKey) {
            let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
            return anchor
        }
        return nil
    }

    func enablePushNotifications(provisional: Bool = true) {
        let authorizationOptions: UNAuthorizationOptions = provisional ? [.alert, .sound, .badge, .provisional] : [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions) { granted, error in
            if let _ = error {
                return
            }

            if granted {
                UserDefaults.standard.set(true, forKey: HAS_ENABLED_PUSH_NOTIFICATIONS_KEY)
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                Task {
                    let requestData: [String: Any] = [
                        "notification_settings": [
                            "push_notifications_enabled": true
                        ]
                    ]

                    do {
                        _ = try await apiCall(urlPath: "/users/notifications/settings", requestData: requestData)
                    } catch {
                        AppLogger.instance("Networking").error("Error updating user notification settings: \(error.localizedDescription, privacy: .public)")
                    }
                }
            } else {
                UserDefaults.standard.set(false, forKey: HAS_ENABLED_PUSH_NOTIFICATIONS_KEY)
                Task {
                    await self.disablePushNotifications()
                }
            }
        }
    }

    func disablePushNotifications() async {
        UserDefaults.standard.set(false, forKey: HAS_ENABLED_PUSH_NOTIFICATIONS_KEY)
        let requestData: [String: Any] = [
            "notification_settings": [
                "push_notifications_enabled": false
            ]
        ]

        do {
            _ = try await apiCall(urlPath: "/users/notifications/settings", requestData: requestData)
        } catch {
            AppLogger.instance("Networking").error("Error updating user notification settings: \(error.localizedDescription, privacy: .public)")
        }
    }

    @objc private func handleDeviceTokenNotification(_ notification: Notification) {
        let session = Session.shared
        if let token = notification.userInfo?["token"] as? String, session.isLoggedIn {
            Task {
                await sendDeviceTokenToServer(token: token)
            }
        }
    }

    func sendDeviceTokenToServer(token: String) async {
        let requestData: [String: Any] = [
            "token": token,
            "device_type": "ios"
        ]

        do {
            _ = try await apiCall(urlPath: "/devices", requestData: requestData)
        } catch {
            AppLogger.instance("Networking").error("Error adding device token: \(error.localizedDescription, privacy: .public)")
        }
    }

    func handleBackgroundFetchNotification(_ userInfo: [AnyHashable: Any]) {
        guard let notificationType = userInfo["type"] as? String, let notificationId = userInfo["notification_id"] as? String else {
            return
        }

        if let notificationType = NotificationType(rawValue: notificationType) {
            switch notificationType {
            case .updatedChatSuggestions:
                updatedChatSuggestions = true
            default:
                break
            }
        }

        Task {
            await markNotificationRead(notificationId)
        }
    }

    func handleForegroundNotification(_ userInfo: [AnyHashable: Any]) {
        guard let notificationType = userInfo["type"] as? String, let data = userInfo["data"] as? [String: Any], let notificationId = userInfo["notification_id"] as? String else {
            return
        }

        if let notificationType = NotificationType(rawValue: notificationType) {
            switch notificationType {
            case .newLabResults:
                createAlertFromNotificationData(data)
            case .updatedHealthSuggestions:
                updatedHealthSuggestions = true
            default:
                break
            }
        }

        Task {
            await markNotificationRead(notificationId)
        }
    }

    func handleNotificationOpened(_ userInfo: [AnyHashable: Any]) {
        guard let notificationType = userInfo["type"] as? String, let data = userInfo["data"] as? [String: Any], let notificationId = userInfo["notification_id"] as? String else {
            return
        }

        if let notificationType = NotificationType(rawValue: notificationType) {
            switch notificationType {
            case .newMessage:
                openUpConversation(data)
            case .newCheckIn:
                openUpConversation(data)
            case .newLabResults:
                createAlertFromNotificationData(data)
            case .labTestOrderUpdate:
                showOverviewTab(data)
            default:
                break
            }
        }

        Task {
            await markNotificationRead(notificationId)
        }
    }

    func openUpConversation(_ data: [AnyHashable: Any]) {
        if let conversationId = data["conversation_id"] as? String {
            DispatchQueue.main.async {
                self.conversationNotificationOpenedId = conversationId
            }
        }
    }

    func showOverviewTab(_ data: [AnyHashable: Any]) {
        DispatchQueue.main.async {
            self.labTestOrderNotificationOpened = true
        }
    }

    func createAlertFromNotificationData(_ data: [AnyHashable: Any]) {
        if let title = data["title"] as? String, let message = data["message"] as? String {
            if let chatPrompt = data["chat_prompt"] as? String {
                self.notificationAlert = NotificationAlert(title: title, message: message, chatPrompt: chatPrompt)
            } else {
                self.notificationAlert = NotificationAlert(title: title, message: message)
            }

        }
    }

    func markNotificationRead(_ notificationId: String) async {
        do {
            _ = try await apiCall(urlPath: "/users/notifications/\(notificationId)/read", requestData: nil)
        } catch {
            AppLogger.instance("Networking").error("Error marking notificiation read: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func startedSyncingHealthData(inBackground: Bool? = false) async throws {
        DispatchQueue.main.async {
            if let inBackground = inBackground {
                if inBackground == true {
                    self.isSyncingHealthDataInBackground = true
                    UserDefaults.standard.set(true, forKey: IS_SYNCING_HEALTH_DATA_IN_BACKGROUND)
                }
            }

            self.isSyncingAllHealthData = true
            UserDefaults.standard.set(true, forKey: IS_SYNCING_ALL_HEALTH_DATA)
        }
        do {
            UserDefaults.standard.set(false, forKey: HAS_COMPLETED_HEALTH_DATA_SYNC)
            _ = try await apiCall(urlPath: "/users/data_sync/start", requestData: nil)
        } catch {
            DispatchQueue.main.async {
                self.isSyncingAllHealthData = false
                UserDefaults.standard.set(false, forKey: IS_SYNCING_ALL_HEALTH_DATA)
                if let inBackground = inBackground {
                    if inBackground == true {
                        self.isSyncingHealthDataInBackground = false
                        UserDefaults.standard.set(false, forKey: IS_SYNCING_HEALTH_DATA_IN_BACKGROUND)
                    }
                }
            }
            throw error
        }
    }

    public func completedSyncingHealthData(inBackground: Bool? = false) async {
        DispatchQueue.main.async {
            self.isSyncingAllHealthData = false
            UserDefaults.standard.set(false, forKey: IS_SYNCING_ALL_HEALTH_DATA)
            if let inBackground = inBackground {
                if inBackground == true {
                    self.isSyncingHealthDataInBackground = false
                    UserDefaults.standard.set(false, forKey: IS_SYNCING_HEALTH_DATA_IN_BACKGROUND)
                }
            }
        }
        do {
            UserDefaults.standard.set(true, forKey: HAS_COMPLETED_HEALTH_DATA_SYNC)
            _ = try await apiCall(urlPath: "/users/data_sync/complete", requestData: nil)
        } catch {
            AppLogger.instance("Networking").error("Error completing data sync with server: \(error.localizedDescription, privacy: .public)")
        }
    }
}

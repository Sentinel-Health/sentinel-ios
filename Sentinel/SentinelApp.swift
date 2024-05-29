import SwiftUI
import HealthKit
import UserNotifications
import NotificationCenter

@main
struct SentinelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init () {
        setup()
    }

    private func setup() {
        if Session.shared.isLoggedIn {
            // Call on startup to get the latest device token
            AppState.shared.enablePushNotifications()

            if AppState.shared.hasAuthorizedHealthKit {
                Task {
                    await HealthKitService.shared.setupHealthKitBackgroundDelivery()
                }
            }

            if AppState.shared.hasAuthorizedHealthRecords {
                Task {
                    await HealthKitService.shared.setupHealthRecordsBackgroundDelivery()
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if Session.shared.isLoggedIn {
            // Login user to various services
            if let _ = Session.shared.currentUser {
                Task {
                    await Session.shared.syncTimezone()
                }
            } else {
                AppLogger.instance("AppSetup").info("no userId on startup")
            }
        }

        let hasEnabledNotifications = UserDefaults.standard.bool(forKey: HAS_ENABLED_PUSH_NOTIFICATIONS_KEY)
        if hasEnabledNotifications {
            UIApplication.shared.registerForRemoteNotifications()
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()

        NotificationCenter.default.post(name: .didReceiveDeviceToken, object: nil, userInfo: ["token": token])
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UserDefaults.standard.set(false, forKey: HAS_ENABLED_PUSH_NOTIFICATIONS_KEY)
    }

    /// Handles receiving remote notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppLogger.instance("Notifications").info("received background fetch notification: \(userInfo)")
        AppState.shared.handleBackgroundFetchNotification(userInfo)
        completionHandler(.newData)
    }

    /// Handles receiving notifications when app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        AppState.shared.handleForegroundNotification(userInfo)
        completionHandler([])
    }

    /// Handles receiving notifications when app is opened from notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        AppState.shared.handleNotificationOpened(userInfo)
        completionHandler()
    }
}

extension Notification.Name {
    static let didReceiveDeviceToken = Notification.Name("didReceiveDeviceToken")
}

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor(Color.primary)
    }
}

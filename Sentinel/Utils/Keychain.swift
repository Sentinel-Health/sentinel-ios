import Foundation
import UIKit
import Security

func keychainServiceName() -> String {
    return "\(Bundle.main.bundleIdentifier!).keys"
}

func setKeychainValue(_ data: Data, for key: String) {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrAccount as String: key,
                                kSecValueData as String: data,
                                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                                kSecAttrService as String: keychainServiceName()]

    // Try to delete any existing item first
    SecItemDelete(query as CFDictionary)

    // Add the new item with the specified accessibility option
    let status = SecItemAdd(query as CFDictionary, nil)

    guard status == errSecSuccess else {
        let errorMessage = "Error setting keychain item: \(status)"
        AppLogger.instance("Keychain").error("\(errorMessage, privacy: .public)")
        return
    }
}

func getKeychainValue(for key: String) -> Data? {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrAccount as String: key,
                                kSecReturnData as String: kCFBooleanTrue!,
                                kSecMatchLimit as String: kSecMatchLimitOne,
                                kSecAttrService as String: keychainServiceName()]

    let maxRetries = 3
    var lastError: OSStatus?

    for attempt in 1...maxRetries {
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess, let data = item as? Data {
            return data
        } else if AppState.shared.isInBackground {
            switch status {
            /// Occasionally, when trying to fetch something from the Keychain in the background fails.
            /// Retry it again before indicating a complete failure. This is especially necessary when failure can mean being logged out of the application.
            case errSecItemNotFound:
                let errorMessage = "Attempt \(attempt): Error retrieving keychain item: \(status)"
                AppLogger.instance("Keychain").error("\(errorMessage, privacy: .public)")
                lastError = status
                if attempt < maxRetries {
                    let sleepTime = TimeInterval(attempt)
                    Thread.sleep(forTimeInterval: sleepTime)
                }
            default:
                let errorMessage = "Error retrieving keychain item in background: \(status)"
                AppLogger.instance("Keychain").error("\(errorMessage, privacy: .public)")
                return nil
            }
        } else {
            let errorMessage = "Error retrieving keychain item: \(status)"
            AppLogger.instance("Keychain").error("\(errorMessage, privacy: .public)")
            return nil
        }
    }

    let finalError = "Final attempt retrieving keychain items in background failed with error: \(String(describing: lastError))"
    AppLogger.instance("Keychain").error("\(finalError, privacy: .public)")
    return nil
}

func deleteKeychainValue(for key: String) {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrAccount as String: key,
                                kSecAttrService as String: keychainServiceName()]

    let status = SecItemDelete(query as CFDictionary)

    guard status == errSecSuccess || status == errSecItemNotFound else {
        let errorMessage = "Error deleting keychain item: \(status)"
        AppLogger.instance("Keychain").error("\(errorMessage, privacy: .public)")
        return
    }
}

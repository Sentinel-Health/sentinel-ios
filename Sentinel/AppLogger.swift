import Foundation
import OSLog

struct AppLogger {
    private static let defaultCategory = "General"

    static func instance(_ category: String = defaultCategory) -> Logger {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: category)
        return logger
    }
}

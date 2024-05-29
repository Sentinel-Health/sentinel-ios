import Foundation
import SwiftUI
import HealthKit

let INIT_ERROR = "HEALTHKIT_INIT_ERROR"
let INIT_ERROR_MESSAGE = "HealthKit not initialized"
let TYPE_IDENTIFIER_ERROR = "HEALTHKIT_TYPE_IDENTIFIER_NOT_RECOGNIZED_ERROR"
let GENERIC_ERROR = "HEALTHKIT_ERROR"

let HKCharacteristicTypeIdentifier_PREFIX = "HKCharacteristicTypeIdentifier"
let HKQuantityTypeIdentifier_PREFIX = "HKQuantityTypeIdentifier"
let HKCategoryTypeIdentifier_PREFIX = "HKCategoryTypeIdentifier"
let HKCorrelationTypeIdentifier_PREFIX = "HKCorrelationTypeIdentifier"
let HKClinicalTypeIdentifier_PREFIX = "HKClinicalTypeIdentifier"
let HKDocumentTypeIdentifier_PREFIX = "HKDocumentTypeIdentifier"
let HKActivitySummaryTypeIdentifier = "HKActivitySummaryTypeIdentifier"
let HKAudiogramTypeIdentifier = "HKAudiogramTypeIdentifier"
let HKWorkoutTypeIdentifier = "HKWorkoutTypeIdentifier"
let HKWorkoutRouteTypeIdentifier = "HKWorkoutRouteTypeIdentifier"
let HKDataTypeIdentifierHeartbeatSeries = "HKDataTypeIdentifierHeartbeatSeries"

let SpeedUnit = HKUnit(from: "m/s") // HKUnit.meter().unitDivided(by: HKUnit.second())
// Support for MET data: HKAverageMETs 8.24046 kcal/hr·kg
let METUnit = HKUnit(from: "kcal/hr·kg")

let API_BASE_URL = "http://localhost:3000/v1"
let APP_BASE_URL = "http://localhost:3000"
let MARKETING_WEBSITE_BASE_URL = "http://localhost:3000"
let HOST = "localhost"

let SESSION_TOKEN_KEY = "sessionToken"
let REFRESH_TOKEN_KEY = "refreshToken"
let TOKEN_EXPIRATION_KEY = "sessionTokenExpiration"
let CURRENT_USER_KEY = "currentUser"

// Onboarding
let DEVICE_ONBOARDING_CONNECT_APPLE_HEALTH_VIEW_INDEX: Int = 0
let DEVICE_ONBOARDING_ENABLE_NOTIFICATIONS_VIEW_INDEX: Int = 1

let ONBOARDING_CONSENTS_VIEW_INDEX: Int = 0
let ONBOARDING_CONNECT_HEALTH_DATA_VIEW_INDEX: Int = 1
let ONBOARDING_COLLECT_MEMBER_INFO_VIEW_INDEX: Int = 2
let ONBOARDING_COLLECT_INTEREST_REASONS_VIEW_INDEX: Int = 3
let ONBOARDING_VERIFY_RECORDS_VIEW_INDEX: Int = 4
let ONBOARDING_ENABLE_NOTIFICATIONS_VIEW_INDEX: Int = 5

// UserDefaults Keys
let USER_ID_KEY = "userId"
let ONBOARDING_CURRENT_PAGE_KEY = "currentOnboardingPage"
let HAS_COMPLETED_ONBOARDING_KEY = "hasCompletedOnboarding"
let DEVICE_ONBOARDING_CURRENT_PAGE_KEY = "currentDeviceOnboardingPage"
let HAS_COMPLETED_DEVICE_ONBOARDING_KEY = "hasCompletedDeviceOnboarding"
let HAS_ENABLED_PUSH_NOTIFICATIONS_KEY = "hasEnabledNotifications"
let HAS_AUTHORIZED_HEALTH_RECORDS_KEY = "hasAuthorizedHealthRecords"
let HAS_AUTHORIZED_HEALTH_KIT_KEY = "hasAuthorizedHealthKit"
let HAS_SETUP_HEALTH_KIT_BACKGROUND_DELIVERY = "hasSetupHealthKitBackgroundDelivery"
let HAS_SETUP_HEALTH_RECORDS_BACKGROUND_DELIVERY = "hasSetupHealthRecordsBackgroundDelivery"
let IS_SYNCING_HEALTH_DATA_IN_BACKGROUND = "isSyncingHealthDataInBackground"
let IS_SYNCING_ALL_HEALTH_DATA = "isSyncingAllHealthData"
let HAS_COMPLETED_HEALTH_DATA_SYNC = "hasCompletedHealthDataSync"
let HAS_COMPLETED_FULL_SYNC = "hasCompletedFullSync"
let HAS_DISMISSED_DATA_ALERT = "hasDismissedDataAlert"
let INTERCOM_USER_LOGGED_IN_KEY = "intercomUserIsLoggedIn"
let LAST_FAILED_HEALTH_KIT_SYNC_DATE = "lastFailedHealthKitSyncDate"

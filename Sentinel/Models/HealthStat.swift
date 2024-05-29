import Foundation

struct HealthStat: Codable {
    var latestMeasurement: HealthDataMeasurement?
    var trendMeasurement: HealthDataMeasurement?
    var measurementTrend: HealthDataMeasurementTrend?
    var measurementTargetRange: HealthDataMeasurementTargetRange?
}

struct HealthDataMeasurement: Codable {
    var value: Double
    var unit: String?
    var from: String?
    var description: String?
}

struct HealthDataMeasurementTrend: Codable {
    var trend: String
    var direction: String
    var description: String?
}

struct HealthDataMeasurementTargetRange: Codable {
    var low: Double?
    var high: Double?
    var description: String?
}

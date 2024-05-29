import Foundation

struct BodyStats: Codable {
    var height: HealthStat?
    var weight: HealthStat?
    var bodyFat: HealthStat?
    var bmi: HealthStat?
}

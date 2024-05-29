import Foundation

struct FitnessStats: Codable {
    var steps: HealthStat?
    var workouts: HealthStat?
    var restingHeartRate: HealthStat?
    var vo2Max: HealthStat?
    var respiratoryRate: HealthStat?
}

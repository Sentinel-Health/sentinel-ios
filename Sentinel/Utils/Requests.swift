import Foundation

func randomBatchSize(min: Int = 1000, max: Int = 2000) -> Int {
    return Int.random(in: min...max)
}

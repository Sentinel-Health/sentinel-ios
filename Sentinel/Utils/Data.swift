import Foundation
import SwiftUI

func determineTrend(currentCount: Double?, previousCount: Double?, reverse: Bool? = false) -> (String, Color, String) {
    guard let current = currentCount, let previous = previousCount, previous != 0 else {
        return ("arrow.left.and.right.circle", .gray, "Steady")
    }

    let percentChange = ((current - previous) / previous) * 100
    switch percentChange {
    case let x where x > 5:
        if reverse == true {
            return ("arrow.up.forward.circle", .red, "Increasing")
        }
        return ("arrow.up.forward.circle", .green, "Increasing")
    case let x where x < -5:
        if reverse == true {
            return ("arrow.down.forward.circle", .green, "Decreasing")
        }
        return ("arrow.down.forward.circle", .red, "Decreasing")
    default:
        return ("arrow.left.and.right.circle", .gray, "Steady")
    }
}

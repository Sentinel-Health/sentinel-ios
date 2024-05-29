import Foundation

func formatNumber(_ num: Double, maximumDecimals: Int = 0, numberStyle: NumberFormatter.Style = .decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = numberStyle
    formatter.maximumFractionDigits = maximumDecimals
    if let formattedValue = formatter.string(for: num) {
        return formattedValue
    } else {
        return "\(num)"
    }
}

func formatFloat(_ num: Float, maximumDecimals: Int = 0, numberStyle: NumberFormatter.Style = .decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = numberStyle
    formatter.maximumFractionDigits = maximumDecimals
    if let formattedValue = formatter.string(for: num) {
        return formattedValue
    } else {
        return "\(num)"
    }
}

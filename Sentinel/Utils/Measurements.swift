import Foundation

func heightUnitFromString(_ unitString: String?) -> UnitLength? {
    switch unitString?.lowercased() {
    case "meters", "meter", "m":
        return UnitLength.meters
    case "centimeters", "centimeter", "cm":
        return UnitLength.centimeters
    case "feet", "foot", "ft":
        return UnitLength.feet
    case "inches", "inch", "in":
        return UnitLength.inches
    // Add more cases as needed
    default:
        return nil // or a default UnitLength
    }
}

func formatHeight(_ heightValue: Double, heightUnit: String?) -> String? {
    let unit = heightUnitFromString(heightUnit)
    if unit == .feet {
        let feet = Int(floor(heightValue))
        let inches = formatNumber((heightValue - floor(heightValue)) * 12)
        return "\(feet)'\(inches)\""
    } else {
        let height = formatNumber(heightValue)
        if let heightUnit = heightUnit {
            return "\(height) \(heightUnit)"
        } else {
            return "\(height)"
        }
    }
}

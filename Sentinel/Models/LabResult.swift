import Foundation

struct LabResult: Codable, Identifiable {
    var id: String
    var name: String
    var issued: String?
    var value: Float?
    var valueUnit: String?
    var valueString: String?
    var referenceRangeString: String?
    var source: String?
    var referenceRange: LabResultReferenceRange?
    var biomarker: Biomarker?

    var issuedDate: Date? {
        if let issued, let date = isoStringToDate(issued) {
            return date
        } else if let issued {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
            return dateFormatter.date(from: issued)!
        }

        return nil
    }

    var formattedValue: String? {
        // Define the regex pattern to match the specified formats
        let pattern = "^[<>]=?\\d+(\\.\\d+)?$"

        if let valueString = valueString,
           let regex = try? NSRegularExpression(pattern: pattern),
           regex.firstMatch(in: valueString, options: [], range: NSRange(location: 0, length: valueString.utf16.count)) != nil {
            // If valueString matches the pattern, return it
            return valueString
        } else {
            // Otherwise, return the formatted value
            if let value = value {
                return formatFloat(value, maximumDecimals: 3)
            }
            return nil
        }
    }

    var outOfReferenceRange: Bool {
        guard let value = value, let referenceRange = referenceRange else {
            return false
        }
        return value < referenceRange.low ?? 0 ||
               value > referenceRange.high ?? .infinity
    }
}

struct LabResultReferenceRange: Codable {
    var low: Float?
    var high: Float?
}

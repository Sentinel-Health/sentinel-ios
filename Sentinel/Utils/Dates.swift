import Foundation

func yearsAgo(numOfYears: Int) -> Date {
    let now = Date()
    let yearsAgo = Calendar.current.date(byAdding: .year, value: -numOfYears, to: now)!
    return yearsAgo
}

func monthsAgo(numOfMonths: Int) -> Date {
    let now = Date()
    let monthsAgo = Calendar.current.date(byAdding: .month, value: -numOfMonths, to: now)!
    return monthsAgo
}

func daysAgo(numOfDays: Int) -> Date {
    let now = Date()
    let daysAgo = Calendar.current.date(byAdding: .day, value: -numOfDays, to: now)!
    return daysAgo
}

func stringToDate(_ str: String, format: String = "yyyy-MM-dd") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: str)
}

func isoStringToDate(_ str: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: str)
}

func dateToIsoString(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let dateString = formatter.string(from: date)
    return dateString
}

func dateString(_ date: Date, style: DateFormatter.Style = .short) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = style
    let dateString = dateFormatter.string(from: date)
    return dateString
}

func formatRelativeDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let dateFormatter = DateFormatter()

    if calendar.isDateInToday(date) {
        let startOfDay = calendar.startOfDay(for: now)
        if date == startOfDay {
            // The date is today and at midnight
            return "Today"
        } else {
            dateFormatter.dateFormat = "h:mm a" // Time format
            return dateFormatter.string(from: date)
        }
    } else if calendar.isDateInYesterday(date) {
        return "Yesterday"
    } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
        dateFormatter.dateFormat = "MMM d" // Just the month and day for dates within the same year
        return dateFormatter.string(from: date)
    } else {
        dateFormatter.dateFormat = "MMM yyyy" // Shortened date string for everything else
        return dateFormatter.string(from: date)
    }
}

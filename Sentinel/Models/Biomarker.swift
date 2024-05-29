import Foundation

struct Biomarker: Codable, Identifiable, Equatable {
    static func == (lhs: Biomarker, rhs: Biomarker) -> Bool {
        lhs.id == rhs.id
    }

    var id: String
    var name: String
    var description: String?
    var unit: String?
    var alternativeNames: [String]?
    var samples: [LabResult]?
    var category: String?
    var subcategory: String?

    struct SampleKey: Hashable {
        let date: Date?
        let value: Float?

        init(date: Date?, value: Float?) {
            if let date = date {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: date)
                self.date = calendar.date(from: components)
            } else {
                self.date = nil
            }
            self.value = value
        }
    }

    var filteredAndSortedSamples: [LabResult] {
        let grouped = Dictionary(grouping: samples ?? []) { (sample) -> SampleKey in
            SampleKey(date: sample.issuedDate, value: sample.value)
        }

        let reduced = grouped.values.compactMap { (group: [LabResult]) -> LabResult? in
            if group.count > 1 {
                return group.reduce(nil) { (currentBest: LabResult?, contender: LabResult) -> LabResult? in
                    guard let currentBest = currentBest else {
                        return contender
                    }

                    if currentBest.referenceRange != nil && contender.referenceRange != nil {
                        return currentBest
                    } else if contender.referenceRange != nil {
                        return contender
                    }
                    return currentBest
                }
            } else {
                return group.first
            }
        }

        return reduced.sorted { a, b in
            switch (a.issuedDate, b.issuedDate) {
            case let (date1?, date2?):
                if date1 == date2 {
                    // If the dates are the same, prioritize samples with a value
                    return a.value != nil && b.value == nil
                }
                return date1 > date2
            case (nil, _):
                return false
            case (_, nil):
                return true
            }
        }
    }
}

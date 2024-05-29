import Foundation
import SwiftUI

struct BiomarkerCategory: Codable, Identifiable {
    var id: String
    var name: String
    var subcategories: [BiomarkerSubcategory]
}

extension BiomarkerCategory {
    func biomarkerStatus() -> (message: String, iconName: String, color: Color) {
        let totalCount = subcategories.flatMap { $0.biomarkers }.count
        let outOfRange = subcategories.flatMap { $0.biomarkers }
            .filter { biomarker in
                guard let latestSample = biomarker.filteredAndSortedSamples.sorted(by: { $0.issuedDate ?? Date() > $1.issuedDate ?? Date() }).first,
                      let value = latestSample.value,
                      let referenceRange = latestSample.referenceRange else {
                    return false
                }
                return value < referenceRange.low ?? 0 ||
                       value > referenceRange.high ?? .infinity
            }

        switch outOfRange.count {
        case 0:
            return ("All within reference range", "checkmark.circle", Color.green)
        case totalCount:
            return ("All outside reference range", "exclamationmark.circle", Color.red)
        default:
            let outOfRangeNames = outOfRange.compactMap { $0.name }.joined(separator: ", ")
            return ("\(outOfRange.count) marker outside reference range: \(outOfRangeNames)", "exclamationmark.triangle", Color.orange)
        }
    }

    var hasSamples: Bool {
        return subcategories.contains { subcategory in
            subcategory.biomarkers.contains { biomarker in
                if let samples = biomarker.samples {
                    return !samples.isEmpty
                } else {
                    return false
                }
            }
        }
    }
}

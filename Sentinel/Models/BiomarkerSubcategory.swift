import Foundation

struct BiomarkerSubcategory: Codable, Identifiable {
    var id: String
    var name: String
    var biomarkers: [Biomarker]
}

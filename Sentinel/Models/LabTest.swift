import Foundation

struct LabTest: Codable, Identifiable {
    var id: String
    var name: String
    var shortDescription: String
    var markdownDescription: String
    var category: String
    var price: String
    var collectionInstructions: String?
    var appointmentUrl: String?
    var afterOrderInstructions: String?
    var isFastingRequired: Bool
    var fastingInstructions: String?
    var hasAdditionalPreparationInstructions: Bool
    var additionalPreparationInstructions: String?
    var labName: String?
    var createdAt: String
    var updatedAt: String
    var order: Int
    var biomarkers: [Biomarker]?
}

import Foundation
import SwiftUI

struct LabTestOrder: Codable, Identifiable {
    var id: String
    var orderNumber: Int
    var status: String
    var amount: String
    var detailedStatus: String?
    var resultsHaveBeenViewed: Bool?
    var requisitionFormUrl: String?
    var resultsPDFUrl: String?
    var additionalInfo: String?
    var createdAt: String
    var updatedAt: String
    var labTest: LabTest
    var resultsStatus: String?
    var resultsReportedAt: String?
    var resultsCollectedAt: String?
    var results: [LabResult]

    var statusLabel: String {
        switch status {
        case "received":
            switch detailedStatus {
            case "ordered":
                return "Order Received"
            case "requisition_created":
                return "Ready for Test"
            default:
                return "Order Received"
            }
        case "collecting_sample":
            switch detailedStatus {
            case "appointment_scheduled":
                return "Appointment Scheduled"
            case "draw_completed":
                return "Blood Draw Completed"
            case "appointment_cancelled":
                return "Appointment Cancelled"
            default:
                return "Processing Test"
            }
        case "sample_with_lab":
            switch detailedStatus {
            case "partial_results":
                return "Processing Test"
            default:
                return "Processing Test"
            }
        case "completed":
            switch detailedStatus {
            default:
                return "Results Available"
            }
        case "cancelled":
            switch detailedStatus {
            default:
                return "Order Cancelled"
            }
        case "failed":
            switch detailedStatus {
            default:
                return "Problem with Sample"
            }
        default:
            return "Unknown status"
        }
    }

    var statusColor: Color {
        switch status {
        case "received":
            switch detailedStatus {
            case "ordered":
                return .secondary
            case "requisition_created":
                return .mint
            default:
                return .secondary
            }
        case "collecting_sample":
            return .orange
        case "sample_with_lab":
            return .orange
        case "completed":
            return .green
        case "cancelled":
            return .secondary
        case "failed":
            return .red
        default:
            return .secondary
        }
    }

    var statusIconName: String {
        switch status {
        case "received":
            switch detailedStatus {
            case "ordered":
                return "cart"
            case "requisition_created":
                return "testtube.2"
            default:
                return "hourglass"
            }
        case "collecting_sample":
            return "arrow.triangle.2.circlepath"
        case "sample_with_lab":
            return "building"
        case "completed":
            return "checkmark.circle"
        case "cancelled":
            return "nosign"
        case "failed":
            return "exclamationmark.circle"
        default:
            return "hourglass"
        }
    }

    var resultsStatusLabel: String {
        switch resultsStatus {
        case "partial":
            return "Partial"
        case "final":
            return "Final"
        default:
            return "Final"
        }
    }
}

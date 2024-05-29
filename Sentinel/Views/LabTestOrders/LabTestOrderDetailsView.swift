import SwiftUI
import MarkdownUI

struct LabTestOrderDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    let labTestOrder: LabTestOrder

    var body: some View {
        List {
            Section(header: SectionHeaderView(title: "Order Details")) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(labTestOrder.labTest.name)
                                .font(.headline)

                            if let orderedOn = isoStringToDate(labTestOrder.createdAt) {
                                Text(dateString(orderedOn, style: .medium))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if let labName = labTestOrder.labTest.labName {
                                Text("Lab: \(labName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text("Order #: \(String(labTestOrder.orderNumber))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(labTestOrder.amount)
                            .font(.system(.body, design: .rounded))
                    }
                }

                if labTestOrder.status != "completed" &&
                    labTestOrder.status != "sample_with_lab" &&
                    labTestOrder.status != "cancelled" &&
                    labTestOrder.status != "failed" {
                    HStack {
                        Text("Requires Fasting")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(labTestOrder.labTest.isFastingRequired ? "Yes" : "No")
                    }
                }

                HStack {
                    Text("Status")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: labTestOrder.statusIconName)
                        .foregroundStyle(labTestOrder.statusColor)
                    Text(labTestOrder.statusLabel)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(labTestOrder.statusColor)
                }
            }

            Section {
                if labTestOrder.detailedStatus != "ordered" &&
                    labTestOrder.status != "completed" &&
                    labTestOrder.status != "sample_with_lab" &&
                    labTestOrder.status != "cancelled" &&
                    labTestOrder.status != "failed" {
                    if let labOrderForm = labTestOrder.requisitionFormUrl {
                        Button("Lab Order Form PDF") {
                            UIApplication.shared.open(URL(string: labOrderForm)!)
                        }
                    }

                    if let appointmentUrl = labTestOrder.labTest.appointmentUrl {
                        Button("Book an appointment") {
                            UIApplication.shared.open(URL(string: appointmentUrl)!)
                        }
                    }
                }

                if labTestOrder.detailedStatus == "completed" || labTestOrder.detailedStatus == "partial_results" {
                    if !labTestOrder.results.isEmpty {
                        NavigationLink {
                            LabTestOrderResultsView(labTestOrder: labTestOrder)
                                .navigationTitle("Lab Test Results")
                                .environmentObject(chatViewModel)
                                .environmentObject(tabsViewModel)
                        } label: {
                            Text("View Results")
                        }
                    } else {
                        /// This really shouldn't happen in production but just in case
                        Text("There was an issue getting your results. Please check back soon or contact support.")
                            .foregroundStyle(.secondary)
                    }

                    if let resultsPDFUrl = labTestOrder.resultsPDFUrl {
                        Button("View Results PDF") {
                            UIApplication.shared.open(URL(string: resultsPDFUrl)!)
                        }
                    }
                }
            }

            if let additionalInfo = labTestOrder.additionalInfo {
                Section(header: SectionHeaderView(title: "Additional Info")) {
                    Markdown(additionalInfo)
                }
            }
        }
        .listSectionSpacing(.compact)
    }
}

// #Preview {
//    LabTestOrderDetailsView()
// }

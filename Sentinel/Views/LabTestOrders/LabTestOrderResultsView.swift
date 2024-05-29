import SwiftUI

struct LabTestOrderResultsView: View {
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    @StateObject var viewModel: LabTestOrderResultsViewModel

    let labTestOrder: LabTestOrder

    init(labTestOrder: LabTestOrder) {
        self.labTestOrder = labTestOrder
        _viewModel = StateObject(wrappedValue: LabTestOrderResultsViewModel(labTestOrder: labTestOrder))
    }

    private let categoryOrder: [String] = [
        "Cardiovascular Health",
        "Metabolic Health",
        "Liver Health",
        "Kidney Health",
        "Blood Health",
        "Vitamins, Minerals & Electrolytes",
        "Fatty Acids"
    ]

    private var groupedResults: [String: [String: [LabResult]]] {
        var result = [String: [String: [LabResult]]]()

        for labResult in labTestOrder.results {
            let category = labResult.biomarker?.category ?? "Uncategorized"
            let subcategory = labResult.biomarker?.subcategory ?? ""

            if result[category] == nil {
                result[category] = [String: [LabResult]]()
            }

            if result[category]?[subcategory] == nil {
                result[category]?[subcategory] = [LabResult]()
            }

            result[category]?[subcategory]?.append(labResult)
        }

        return result
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(labTestOrder.labTest.name)
                        .font(.headline)

                    if let collectedAt = labTestOrder.resultsCollectedAt, let collectedAtDate = isoStringToDate(collectedAt) {
                        Text("Collected on: \(dateString(collectedAtDate))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text("Results: \(labTestOrder.resultsStatusLabel)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    if let resultsDate = labTestOrder.resultsReportedAt, let date = isoStringToDate(resultsDate) {
                        chatViewModel.startConversationWithPrompt(chatPrompt: "I'd like to discuss my lab results from \(dateString(date, style: .medium))")
                    } else {
                        chatViewModel.startConversationWithPrompt(chatPrompt: "I'd like to discuss my \(labTestOrder.labTest.name) test results with the order number: \(labTestOrder.orderNumber)")
                    }
                    tabsViewModel.changeTab("chat")
                } label: {
                    Text("Discuss results with Sentinel")
                }
            }

            ForEach(groupedResults.keys.sorted {
                if categoryOrder.contains($0) && categoryOrder.contains($1) {
                    return categoryOrder.firstIndex(of: $0)! < categoryOrder.firstIndex(of: $1)!
                } else if categoryOrder.contains($0) {
                    return true
                } else if categoryOrder.contains($1) {
                    return false
                } else {
                    return $0 < $1
                }
            }, id: \.self) { category in
                Section(header: SectionHeaderView(title: category)) {}
                    .headerProminence(.increased)
                    .listSectionSpacing(0)

                ForEach(groupedResults[category]?.keys.sorted() ?? [], id: \.self) { subcategory in
                    if let labResults = groupedResults[category]?[subcategory] {
                        Section(header: SectionHeaderView(title: subcategory)) {
                            ForEach(labResults, id: \.id) { labResult in
                                LabResultCellView(labResult: labResult)
                            }
                        }
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .task {
            do {
                try await viewModel.markViewed()
            } catch {
            }
        }
    }
}

// #Preview {
//    LabTestOrderResultsView()
// }

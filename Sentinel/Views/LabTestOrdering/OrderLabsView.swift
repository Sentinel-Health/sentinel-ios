import SwiftUI

struct OrderLabsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var homeViewModel: HomeViewModel

    var body: some View {
        List {
            Section(header: SectionHeaderView(title: "General"), footer: footerView()) {
                ForEach(homeViewModel.labTests.filter { $0.category == "standard" }.sorted(by: { $0.order < $1.order })) { labTest in
                    LabTestCellView(labTest: labTest)
                }
            }

            if !homeViewModel.labTests.filter({ $0.category == "special" }).isEmpty {
                Section(header: SectionHeaderView(title: "Special"), footer: feedbackView()) {
                    ForEach(homeViewModel.labTests.filter { $0.category == "special" }.sorted(by: { $0.order < $1.order })) { labTest in
                        LabTestCellView(labTest: labTest)
                    }
                }
            }
        }
    }

    func footerView() -> some View {
        if !homeViewModel.unsupportedLabTestStates.isEmpty,
           let unsupportedStatesString = getUnsupportedStatesString() {
            return AnyView(SectionFooterView(text: "Unfortunately, we do not currently support lab tests in \(unsupportedStatesString). If you would like us to support your state, [please let us know](mailto:support@\(HOST))."))
        } else {
            return AnyView(EmptyView())
        }
    }

    func feedbackView() -> some View {
        return AnyView(SectionFooterView(text: "Not seeing something you're looking for? [Let us know what you want](mailto:support@\(HOST))."))
    }

    func getUnsupportedStatesString() -> String? {
        let states = homeViewModel.unsupportedLabTestStates.filter { !NON_US_STATES.contains($0) }
        let formattedString: String
        if states.count > 1 {
            formattedString = "\(states.dropLast().joined(separator: ", ")), or \(states.last!)"
        } else {
            formattedString = states.first ?? ""
        }
        return formattedString
    }
}

#Preview {
    OrderLabsView()
}

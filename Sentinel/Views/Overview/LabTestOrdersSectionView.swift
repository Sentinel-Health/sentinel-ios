import SwiftUI

struct LabTestOrdersSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    var body: some View {
        Section(header: SectionHeaderView(title: "Lab Orders")) {
            ForEach(viewModel.labTestOrders) { labTestOrder in
                LabTestOrderCellView(labTestOrder: labTestOrder)
                    .environmentObject(viewModel)
                    .environmentObject(tabsViewModel)
                    .environmentObject(chatViewModel)
            }
        }
        .headerProminence(.increased)
    }
}

#Preview {
    LabTestOrdersSectionView()
}

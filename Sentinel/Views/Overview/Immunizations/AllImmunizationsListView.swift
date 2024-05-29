import SwiftUI

struct AllImmunizationsListView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    var body: some View {
        List(homeViewModel.immunizations) { immunization in
            ImmunizationCellView(immunization: immunization)
                .environmentObject(homeViewModel)
                .environmentObject(chatViewModel)
                .environmentObject(tabsViewModel)
        }
        .navigationTitle("Vaccines")
    }
}

// #Preview {
//    AllImmunizationsListView()
// }

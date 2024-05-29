import SwiftUI

struct AllAllergiesListView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    var body: some View {
        List(homeViewModel.allergies) { allergy in
            AllergyCellView(allergy: allergy)
                .environmentObject(chatViewModel)
                .environmentObject(homeViewModel)
                .environmentObject(tabsViewModel)
        }
        .navigationTitle("Allergies")
    }
}

// #Preview {
//    AllAllergiesListView()
// }

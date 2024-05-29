import SwiftUI

struct AllConditionsListView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    var body: some View {
        List(homeViewModel.conditions) { condition in
            ConditionCellView(condition: condition)
                .environmentObject(chatViewModel)
                .environmentObject(homeViewModel)
                .environmentObject(tabsViewModel)
        }
        .navigationTitle("Medical Conditions")
    }
}

// #Preview {
//    AllConditionsListView()
// }

import SwiftUI

struct AllProceduresListView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    var body: some View {
        List(homeViewModel.procedures) { procedure in
            ProcedureCellView(procedure: procedure)
                .environmentObject(homeViewModel)
                .environmentObject(chatViewModel)
                .environmentObject(tabsViewModel)
        }
        .navigationTitle("Procedures")
    }
}

// #Preview {
//    AllProceduresListView()
// }

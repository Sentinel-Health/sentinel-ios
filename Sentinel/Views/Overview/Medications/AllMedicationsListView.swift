import SwiftUI

struct AllMedicationsListView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    var body: some View {
        List(homeViewModel.medications) { medication in
            MedicationCellView(medication: medication)
                .environmentObject(chatViewModel)
                .environmentObject(homeViewModel)
                .environmentObject(tabsViewModel)

        }
        .navigationTitle("Medications")
    }
}

// #Preview {
//    AllMedicationsListView()
// }

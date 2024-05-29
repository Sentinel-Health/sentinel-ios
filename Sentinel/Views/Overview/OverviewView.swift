import SwiftUI

struct OverviewView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @StateObject var viewModel: HomeViewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            OverviewListView()
                .environmentObject(viewModel)
                .environmentObject(chatViewModel)
                .environmentObject(tabsViewModel)
                .environmentObject(rootViewModel)
                .navigationTitle("Overview")
        }
    }
}

 #Preview {
    OverviewView()
 }

import SwiftUI

struct AccountView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    var body: some View {
        NavigationStack {
            AccountListView()
                .environmentObject(rootViewModel)
                .environmentObject(tabsViewModel)
                .environmentObject(chatViewModel)
                .navigationTitle("Your Account")
        }
    }
}

// #Preview {
//    AccountView()
// }

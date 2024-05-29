import SwiftUI

struct TabsView: View {
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var viewModel: TabsViewModel = TabsViewModel()
    @StateObject var chatViewModel: ChatViewModel = ChatViewModel()

    @State private var showDeviceOnboarding: Bool = false

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            OverviewView()
                .environmentObject(rootViewModel)
                .environmentObject(chatViewModel)
                .environmentObject(viewModel)
                .tabItem {
                    Label("Overview", systemImage: "heart.text.square")
                }
                .tag("overview")

            ChatView()
                .environmentObject(rootViewModel)
                .environmentObject(chatViewModel)
                .environmentObject(viewModel)
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                .tag("chat")

            AccountView()
                .environmentObject(rootViewModel)
                .environmentObject(viewModel)
                .environmentObject(chatViewModel)
                .tabItem {
                    Label("Account", systemImage: "person")
                }
                .tag("account")
        }
        .sheet(isPresented: $showDeviceOnboarding) {
            DeviceOnboardingView()
                .environmentObject(rootViewModel)
        }
        .onReceive(rootViewModel.$completedDeviceOnboarding) { completed in
            self.showDeviceOnboarding = !completed
        }
        .onReceive(rootViewModel.$showSentinelOnboarding) { showSentinelOnboarding in
            if showSentinelOnboarding {
                viewModel.changeTab("chat")
            }
        }
        .onReceive(AppState.shared.$conversationNotificationOpenedId) { conversationId in
            if let _ = conversationId, viewModel.selectedTab != "chat" {
                viewModel.changeTab("chat")
            }
        }
        .onReceive(AppState.shared.$labTestOrderNotificationOpened) { labTestOrderOpened in
            if labTestOrderOpened {
                viewModel.changeTab("overview")
            }
        }
    }
}

// #Preview {
//    TabsView()
// }

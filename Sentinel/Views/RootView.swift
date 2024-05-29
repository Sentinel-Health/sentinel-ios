import SwiftUI

struct RootView: View {
    @StateObject var rootViewModel: RootViewModel = RootViewModel()

    @State private var isLoading: Bool = true
    @State private var isFetchingUser: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoggedIn: Bool

    init() {
        isLoggedIn = Session.shared.isLoggedIn
    }

    var body: some View {
        Group {
            if isLoading {
                AppLaunchView()
            } else if !isLoggedIn {
                LoginView()
            } else {
                if let currentUser = Session.shared.currentUser, !currentUser.hasCompletedOnboarding {
                    NewUserOnboardingView()
                        .environmentObject(rootViewModel)
                } else {
                    TabsView()
                        .environmentObject(rootViewModel)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("Ok") {
                showError = false
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            Task {
                await fetchUser()
            }
        }
        .onReceive(Session.shared.$isLoggedIn) { isLoggedIn in
            self.isLoggedIn = isLoggedIn
            Task {
                await fetchUser()
            }
        }
    }

    private func fetchUser() async {
        guard !isFetchingUser else { return }

        if isLoggedIn {
            do {
                isLoading = true
                isFetchingUser = true
                try await Session.shared.syncUser()
                isLoading = false
                isFetchingUser = false
            } catch {
                isLoading = false
                isFetchingUser = false
                errorMessage = error.localizedDescription
                showError = true
            }
        } else {
            isLoading = false
        }
    }
}

#Preview {
    RootView()
}

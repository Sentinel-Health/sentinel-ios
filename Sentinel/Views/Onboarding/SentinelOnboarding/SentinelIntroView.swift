import SwiftUI

struct SentinelIntroView: View {
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    @State private var headerOpacity: Double = 0.0
    @State private var progressOpacity: Double = 0.0
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            Text("Say Hello to Sentinel 👋")
                .font(.title)
                .fontWeight(.semibold)
                .padding()
                .opacity(headerOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5)) {
                        headerOpacity = 1.0
                    }
                    Task {
                        do {
                            try await loadInitialConversation()
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }

            ProgressView()
                .padding()
                .opacity(progressOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 2.0)) {
                        progressOpacity = 0.8
                    }
                }
        }
    }

    private func loadInitialConversation() async throws {
        try await chatViewModel.startOnboardingConversation()

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 1.5)) {
                headerOpacity = 0.0
                progressOpacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                rootViewModel.showSentinelOnboarding = false
            }
        }
    }
}

 #Preview {
    SentinelIntroView()
 }

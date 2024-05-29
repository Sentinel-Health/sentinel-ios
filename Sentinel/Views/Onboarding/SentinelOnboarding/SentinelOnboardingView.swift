import SwiftUI

struct SentinelOnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    var body: some View {
        NavigationStack {
            SentinelIntroView()
                .environmentObject(chatViewModel)
                .environmentObject(rootViewModel)
        }
        .interactiveDismissDisabled()
        .presentationDetents([.large])
    }
}

#Preview {
    SentinelOnboardingView()
}

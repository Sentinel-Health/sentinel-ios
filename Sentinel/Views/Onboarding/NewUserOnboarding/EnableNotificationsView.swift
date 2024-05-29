import SwiftUI
import MarkdownUI

struct EnableNotificationsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel

    @State private var showErrorModal: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading) {
                        Image("icon-notification")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(color: Color(UIColor.systemGray), radius: 2)
                            .frame(width: 75, height: 75)
                            .padding(.bottom, 12)

                        Text("Get Notified")
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding(.bottom, 16)

                        Text("Get notifications whenever there's important information for you.")
                            .opacity(0.9)
                            .padding(.bottom, 16)

                        Markdown("**Types of notifications we send:**\n- When there is new data for you to view\n- When you have new personalized recommendations\n- When there is a new message from Sentinel")
                            .opacity(0.9)
                    }
                    .padding()
                    .padding(.top, 40)
                    Spacer()
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                .padding(.top, 1)
            }
            VStack(spacing: 24) {
                AppButton(
                    text: "Enable Notifications",
                    fullWidth: true,
                    action: {
                        AppState.shared.enablePushNotifications(provisional: false)
                        Task {
                           await completeOnboarding()
                        }
                    }
                )
                Button("Skip for Now") {
                    Task {
                        await completeOnboarding()
                    }
                }
                .font(.callout)
                .tint(colorScheme == .dark ? .white : .black)
            }
            .padding()
        }
        .alert("Error", isPresented: $showErrorModal) {
            Button("Ok") {
                showErrorModal = false
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }

    func completeOnboarding() async {
        do {
            try await rootViewModel.completeUserOnboarding()
        } catch {
        }
    }
}

#Preview {
    EnableNotificationsView()
}

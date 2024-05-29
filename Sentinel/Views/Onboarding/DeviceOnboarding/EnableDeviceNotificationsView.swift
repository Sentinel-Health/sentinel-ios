import SwiftUI
import MarkdownUI

struct EnableDeviceNotificationsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var onboardingViewModel: DeviceOnboardingViewModel
    @EnvironmentObject var rootViewModel: RootViewModel

    @State private var showErrorModal: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        VStack(spacing: 16) {
                            Image("icon-notification")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .shadow(color: Color(UIColor.systemGray), radius: 2)
                                .frame(width: 75, height: 75)

                            Text("Get Notified")
                                .font(.title)
                                .bold()

                            Text("Get notifications whenever there's important information for you.")
                                .opacity(0.9)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }

                        Divider()
                            .padding(.vertical)

                        VStack {
                            Markdown("**Types of notifications we send:**\n- When there is new data for you to view\n- When you have new personalized recommendations\n- When there is a new message from Sentinel")
                                .opacity(0.9)
                        }

                    }
                    .padding(.top, 40)
                    .padding(.horizontal)

                    Spacer()
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
            }

            VStack(spacing: 20) {
                AppButton(
                    text: "Enable Notifications",
                    fullWidth: true,
                    action: {
                        AppState.shared.enablePushNotifications(provisional: false)
                        completeOnboarding()
                    }
                )
                Button("Skip for Now") {
                    completeOnboarding()
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

    func completeOnboarding() {
        rootViewModel.completeDeviceOnboarding()
    }
}

#Preview {
    EnableDeviceNotificationsView()
}

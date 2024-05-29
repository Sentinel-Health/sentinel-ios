import SwiftUI

struct DeviceOnboardingView: View {
    @EnvironmentObject var rootViewModel: RootViewModel

    @StateObject var onboardingViewModel: DeviceOnboardingViewModel = DeviceOnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if onboardingViewModel.currentPage == DEVICE_ONBOARDING_CONNECT_APPLE_HEALTH_VIEW_INDEX {
                    ConnectAppleHealthView()
                        .environmentObject(onboardingViewModel)
                } else if onboardingViewModel.currentPage == DEVICE_ONBOARDING_ENABLE_NOTIFICATIONS_VIEW_INDEX {
                    EnableDeviceNotificationsView()
                        .transition(.push(from: .trailing))
                        .environmentObject(onboardingViewModel)
                        .environmentObject(rootViewModel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .interactiveDismissDisabled()
        .presentationDetents([.large])
    }
}

#Preview {
    DeviceOnboardingView()
}

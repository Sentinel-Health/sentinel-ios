import SwiftUI

struct NewUserOnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var onboardingViewModel: OnboardingViewModel = OnboardingViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel

    var body: some View {
        VStack {
            if onboardingViewModel.currentPage == ONBOARDING_CONSENTS_VIEW_INDEX {
                WelcomeAndConsentsView()
                    .environmentObject(onboardingViewModel)
                    .environmentObject(rootViewModel)
            } else if onboardingViewModel.currentPage == ONBOARDING_CONNECT_HEALTH_DATA_VIEW_INDEX {
                ConnectHealthDataView()
                    .transition(.push(from: .trailing))
                    .environmentObject(onboardingViewModel)
                    .environmentObject(rootViewModel)
            } else if onboardingViewModel.currentPage == ONBOARDING_COLLECT_MEMBER_INFO_VIEW_INDEX {
                CollectMemberInfoView()
                    .transition(.push(from: .trailing))
                    .environmentObject(onboardingViewModel)
                    .environmentObject(rootViewModel)
            } else if onboardingViewModel.currentPage == ONBOARDING_COLLECT_INTEREST_REASONS_VIEW_INDEX {
                CollectHealthGoalsView()
                    .transition(.push(from: .trailing))
                    .environmentObject(onboardingViewModel)
                    .environmentObject(rootViewModel)
            } else if onboardingViewModel.currentPage == ONBOARDING_VERIFY_RECORDS_VIEW_INDEX {
                VerifyRecordsView()
                    .transition(.push(from: .trailing))
                    .environmentObject(onboardingViewModel)
                    .environmentObject(rootViewModel)
            } else if onboardingViewModel.currentPage == ONBOARDING_ENABLE_NOTIFICATIONS_VIEW_INDEX {
                EnableNotificationsView()
                    .transition(.push(from: .trailing))
                    .environmentObject(onboardingViewModel)
                    .environmentObject(rootViewModel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// #Preview {
//    NewUserOnboardingView()
// }

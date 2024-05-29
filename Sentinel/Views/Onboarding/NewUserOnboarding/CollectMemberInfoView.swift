import SwiftUI
import HealthKit

struct CollectMemberInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel

    @StateObject var healthProfileFormViewModel: HealthProfileFormViewModel = HealthProfileFormViewModel()

    private let formFieldBackgroundColor: Color = .secondary.opacity(0.1)

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Tell us about yourself")
                        .font(.title)
                        .fontWeight(.semibold)
                }
                .padding(.bottom, 16)

                Text("Sentinel uses this information to provide personalized services and for ordering lab tests. Please fill it out and verify that the information is accurate.")
                    .opacity(0.9)
            }
            .padding(.horizontal)
            .padding(.top, 40)
            .fixedSize(horizontal: false, vertical: true)

            Form {
                HealthProfileFormView(fieldBackgroundColor: colorScheme == .dark ? nil : formFieldBackgroundColor)
                    .environmentObject(healthProfileFormViewModel)
            }
            .scrollContentBackground(colorScheme == .dark ? .automatic : .hidden)
            .scrollBounceBehavior(.basedOnSize)

            VStack {
                AppButton(
                    text: "Continue",
                    fullWidth: true,
                    isLoading: healthProfileFormViewModel.isLoading,
                    action: {
                        Task {
                            await healthProfileFormViewModel.submitForm()
                            if healthProfileFormViewModel.showErrorModal == false {
                                withAnimation {
                                    onboardingViewModel.nextView()
                                }
                            }
                        }
                    }
                )
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .alert("Error", isPresented: $healthProfileFormViewModel.showErrorModal) {
            Button("Ok") {
                healthProfileFormViewModel.showErrorModal = false
            }
        } message: {
            Text(healthProfileFormViewModel.errorMessage)
        }
    }
}

// #Preview {
//    CollectMemberInfoView()
// }

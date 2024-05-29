import SwiftUI

struct WelcomeAndConsentsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel

    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    @State private var acceptedPolicyAndTerms: Bool = false
    @State private var acceptedHIPAAAuthorization: Bool = false

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Welcome to Sentinel!")
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        .padding(.bottom, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("In the next few screens, we're going to get you set up to use Sentinel.")
                                .opacity(0.9)

                            Text("First, we need you to agree to a few things.")
                                .opacity(0.9)
                        }
                        .padding(.bottom, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            CheckboxView(checked: $acceptedHIPAAAuthorization, label: "I have read and agree to the terms of the [HIPAA Authorization](\(MARKETING_WEBSITE_BASE_URL)/hipaa-authorization).", isDisabled: isLoading)
                            CheckboxView(checked: $acceptedPolicyAndTerms, label: "I have read and agree to the [Privacy Policy](\(MARKETING_WEBSITE_BASE_URL)/privacy), [Telehealth Consent Terms](\(MARKETING_WEBSITE_BASE_URL)/telehealth-terms), and [Terms of Service](\(MARKETING_WEBSITE_BASE_URL)/terms).", isDisabled: isLoading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal)
                    Spacer()
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                .padding(.top, 1)
                .scrollBounceBehavior(.basedOnSize)
            }
            VStack {
                AppButton(
                    text: "Continue",
                    fullWidth: true,
                    isDisabled: !acceptedPolicyAndTerms || !acceptedHIPAAAuthorization,
                    isLoading: isLoading,
                    action: {
                        Task {
                            do {
                                try await onboardingViewModel.confirmConsents(data: [
                                    "accepted_policy_and_terms": acceptedPolicyAndTerms,
                                    "accepted_hipaa_authorization": acceptedHIPAAAuthorization
                                ])
                                withAnimation {
                                    onboardingViewModel.nextView()
                                }
                            } catch {
                                isLoading = false
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    }
                )
            }
            .padding()
        }
        .alert("Error", isPresented: $showError) {
            Button("Ok") {
                showError = false
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    WelcomeAndConsentsView()
}

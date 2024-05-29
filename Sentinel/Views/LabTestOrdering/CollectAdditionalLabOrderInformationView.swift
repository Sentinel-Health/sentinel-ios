import SwiftUI

struct CollectAdditionalLabOrderInformationView: View {
    @EnvironmentObject var viewModel: OrderLabTestsViewModel
    @StateObject var addressFormViewModel: AddressFormViewModel = AddressFormViewModel()
    @StateObject var healthProfileFormViewModel: HealthProfileFormViewModel = HealthProfileFormViewModel()
    @StateObject var phoneNumberFormViewModel: PhoneNumberFormViewModel = PhoneNumberFormViewModel()

    let labTestId: String

    @State var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    @State private var acceptedHIPAAAuthorization: Bool = false
    @State private var acceptedTelehealthConsent: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                if viewModel.requiredInformation.contains(.healthProfile) {
                    HealthProfileFormView()
                        .environmentObject(healthProfileFormViewModel)
                }
                if viewModel.requiredInformation.contains(.phoneNumber) {
                    PhoneNumberFormView()
                        .environmentObject(phoneNumberFormViewModel)
                        .listSectionSpacing(0)
                }
                if viewModel.requiredInformation.contains(.address) {
                    AddressFormView()
                        .environmentObject(addressFormViewModel)
                }
                if viewModel.requiredInformation.contains(.hipaaAuthorization) {
                    CheckboxView(checked: $acceptedHIPAAAuthorization, label: "I have read and agree to the terms of the [HIPAA Authorization](\(MARKETING_WEBSITE_BASE_URL)/hipaa-authorization).", isDisabled: isLoading)
                        .listRowSeparator(.hidden)
                        .listRowBackground(EmptyView())
                        .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
                if viewModel.requiredInformation.contains(.telehealthConsent) {
                    CheckboxView(checked: $acceptedTelehealthConsent, label: "I have read and agree to the [Telehealth Consent Terms](\(MARKETING_WEBSITE_BASE_URL)/telehealth-terms).", isDisabled: isLoading)
                        .listRowSeparator(.hidden)
                        .listRowBackground(EmptyView())
                        .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
            }
            .listSectionSpacing(.compact)

            AppButton(
                text: "Continue",
                fullWidth: true,
                isDisabled: isLoading,
                isLoading: isLoading
            ) {
                Task {
                    do {
                        isLoading = true
                        if viewModel.requiredInformation.contains(.address) {
                            await addressFormViewModel.submitForm()
                        }
                        if viewModel.requiredInformation.contains(.healthProfile) {
                            await healthProfileFormViewModel.submitForm()
                        }
                        if viewModel.requiredInformation.contains(.phoneNumber) {
                            phoneNumberFormViewModel.checkPhoneVerification()
                        }
                        if viewModel.requiredInformation.contains(.hipaaAuthorization) || viewModel.requiredInformation.contains(.telehealthConsent) {
                            _ = try await apiCall(urlPath: "/lab_tests/consents/confirm", requestData: [
                                "accepted_telehealth_consent": acceptedTelehealthConsent,
                                "accepted_hipaa_authorization": acceptedHIPAAAuthorization
                            ])
                        }
                        viewModel.requiresAdditionalInformation = false
                        try await viewModel.createCheckout(labTestId: labTestId)
                        isLoading = false
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                        isLoading = false
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
        }
        .alert("Error", isPresented: $showError) {
            Button("Ok") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
}

// #Preview {
//    CollectAdditionalLabOrderInformationView()
// }

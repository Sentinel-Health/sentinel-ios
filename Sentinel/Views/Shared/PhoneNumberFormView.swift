import SwiftUI

struct PhoneNumberFormView: View {
    @EnvironmentObject var viewModel: PhoneNumberFormViewModel

    var body: some View {
        Section(footer: SectionFooterView(text: "Your phone number is required in case a doctor needs to contact you directly about your lab test results.")) {
            LabeledContent {
                TextField("Your Phone Number", text: $viewModel.phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .onChange(of: viewModel.phoneNumber) {
                        viewModel.phoneNumberChanged()
                    }
            } label: {
                Text("Phone Number")
            }

            if viewModel.verificationCodeSent {
                LabeledContent {
                    TextField("Code", text: $viewModel.verificationCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.trailing)
                        .submitLabel(.done)
                } label: {
                    Text("Verification Code")
                }

                HStack {
                    Button("Verify and Save") {
                        Task {
                            await viewModel.verifyPhoneAndSave()
                        }
                    }.disabled(viewModel.isLoading || viewModel.isSendingVerificationCode)
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }

                HStack {
                    Button("Re-send Code") {
                        Task {
                            await viewModel.sendVerificationCode()
                        }
                    }.disabled(viewModel.isSendingVerificationCode || viewModel.isLoading)
                    Spacer()
                    if viewModel.isSendingVerificationCode {
                        ProgressView()
                    }
                }
            } else if !viewModel.isPhoneNumberVerified && viewModel.phoneNumber != "" {
                HStack {
                    Button("Verify Phone Number") {
                        Task {
                            await viewModel.sendVerificationCode()
                        }
                    }.disabled(viewModel.isSendingVerificationCode || viewModel.isLoading)
                    Spacer()
                    if viewModel.isSendingVerificationCode {
                        ProgressView()
                    }
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorModal) {
            Button("Ok") {
                viewModel.showErrorModal = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    PhoneNumberFormView()
}

import Foundation
import SwiftUI

class PhoneNumberFormViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isSendingVerificationCode: Bool = false
    @Published var showErrorModal: Bool = false
    @Published var errorMessage: String = ""

    @Published var phoneNumber: String = Session.shared.currentUser?.phoneNumber ?? ""
    @Published var verificationCode: String = ""
    @Published var verificationCodeSent: Bool = false
    @Published var isPhoneNumberVerified: Bool = Session.shared.currentUser?.phoneNumberVerified ?? false

    @Published var showSuccess: Bool = false

    func phoneNumberChanged() {
        isPhoneNumberVerified = false
    }

    func sendVerificationCode() async {
        DispatchQueue.main.async {
            self.isSendingVerificationCode = true
        }
        do {
            _ = try await apiCall(urlPath: "/users/phone_number/send_verification_code", method: "POST", requestData: [
                "phone_number": phoneNumber
            ])

            DispatchQueue.main.async {
                self.isSendingVerificationCode = false
                self.isPhoneNumberVerified = false
                self.verificationCodeSent = true
            }
        } catch {
            DispatchQueue.main.async {
                self.isSendingVerificationCode = false
                self.errorMessage = error.localizedDescription
                self.showErrorModal = true
            }
        }
    }

    func verifyPhoneAndSave() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            _ = try await apiCall(urlPath: "/users/phone_number/verify", method: "POST", requestData: [
                "verification_code": verificationCode
            ])

            DispatchQueue.main.async {
                self.showSuccess = true
                self.isLoading = false
                self.verificationCode = ""
                self.verificationCodeSent = false
                self.isPhoneNumberVerified = true
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showErrorModal = true
            }
        }
    }

    func checkPhoneVerification() {
        if phoneNumber == "" {
            DispatchQueue.main.async {
                self.errorMessage = "Phone number is required."
                self.showErrorModal = true
            }
        } else if !isPhoneNumberVerified {
            DispatchQueue.main.async {
                self.errorMessage = "Phone number must be verified."
                self.showErrorModal = true
            }
        }

        return
    }

    func resetForm() {
        isLoading = false
        isSendingVerificationCode = false
        showErrorModal = false
        errorMessage = ""
        phoneNumber = Session.shared.currentUser?.phoneNumber ?? ""
        verificationCode = ""
        verificationCodeSent = false
        isPhoneNumberVerified = Session.shared.currentUser?.phoneNumberVerified ?? false
    }
}

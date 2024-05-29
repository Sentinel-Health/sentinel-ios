import Foundation

class AddressFormViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var showErrorModal: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccess: Bool = false

    @Published var street1: String = Session.shared.currentUser?.addressLine1 ?? ""
    @Published var street2: String = Session.shared.currentUser?.addressLine2 ?? ""
    @Published var city: String = Session.shared.currentUser?.city ?? ""
    @Published var state: String = Session.shared.currentUser?.state ?? ""
    @Published var zipCode: String = Session.shared.currentUser?.zipCode ?? ""

    public func updateAddress(data: [String: Any]? = [:]) async throws {
        _ = try await apiCall(urlPath: "/me/update", method: "POST", requestData: data)
        try await Session.shared.syncUser()
    }

    public func loadUser() async {
        do {
            try await Session.shared.syncUser()
            DispatchQueue.main.async {
                self.street1 = Session.shared.currentUser?.addressLine1 ?? ""
                self.street2 = Session.shared.currentUser?.addressLine2 ?? ""
                self.city = Session.shared.currentUser?.city ?? ""
                self.state = Session.shared.currentUser?.state ?? ""
                self.zipCode = Session.shared.currentUser?.zipCode ?? ""
            }
        } catch {
            AppLogger.instance("AddressForm").error("\(error.localizedDescription)")
        }
    }

    public func submitForm() async {
        if street1 == "" {
            DispatchQueue.main.async {
                self.showErrorModal = true
                self.errorMessage = "A street address is required."
            }
        } else if city == "" {
            DispatchQueue.main.async {
                self.showErrorModal = true
                self.errorMessage = "A city is required."
            }
        } else if state == "" {
            DispatchQueue.main.async {
                self.showErrorModal = true
                self.errorMessage = "A state is required."
            }
        } else if zipCode == "" {
            DispatchQueue.main.async {
                self.showErrorModal = true
                self.errorMessage = "A zip code is required."
            }
        } else {
            Task {
                DispatchQueue.main.async {
                    self.isLoading = true
                }
                do {
                    try await updateAddress(data: [
                        "address_line_1": street1,
                        "address_line_2": street2,
                        "city": city,
                        "state": state,
                        "zip_code": zipCode
                    ])
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.showSuccess = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.showErrorModal = true
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

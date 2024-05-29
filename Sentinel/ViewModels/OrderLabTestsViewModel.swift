import Foundation

class OrderLabTestsViewModel: ObservableObject {
    @Published var showLabTestOrderModal: Bool = false
    @Published var showAppointmentPage: Bool = false
    @Published var showOrderConfirmation: Bool = false
    @Published var showCheckoutPage: Bool = false
    @Published var checkoutPageUrl: String?
    @Published var requiresAdditionalInformation: Bool = false
    @Published var requiredInformation: [LabOrderRequirements] = []

    private var sessionToken: String?

    func createCheckout(labTestId: String) async throws {
        let data = try await apiCall(urlPath: "/lab_tests/create_checkout", method: "POST", requestData: [
            "lab_test_id": labTestId
        ])
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            AppLogger.instance("LabTestOrdering").error("Something went wrong trying to parse checkout session json.")
            let error = NSError(domain: Bundle.main.bundleIdentifier!, code: 400, userInfo: [NSLocalizedDescriptionKey: "Something went wrong. Please try again or contact support."])
            throw error
        }

        if let ineligible = json["ineligible"] as? Bool, ineligible, let requirements = json["requirements"] as? [String] {
            /// User is ineligible at the moment, show necessary screens
            DispatchQueue.main.async {
                self.requiresAdditionalInformation = true
                let requiredData = requirements.compactMap { LabOrderRequirements(rawValue: $0) }
                self.requiredInformation = requiredData
            }
            return
        }

        guard let checkoutUrl = json["url"] as? String, let checkoutToken = json["checkoutToken"] as? String else {
            AppLogger.instance("LabTestOrdering").error("Something went wrong trying to parse checkout session json.")
            let error = NSError(domain: Bundle.main.bundleIdentifier!, code: 400, userInfo: [NSLocalizedDescriptionKey: "Something went wrong. Please try again or contact support."])
            throw error
        }

        DispatchQueue.main.async {
            self.sessionToken = checkoutToken
            self.checkoutPageUrl = checkoutUrl
            self.showCheckoutPage = true
        }
    }

    func handleCheckoutNavigation(url: String) {
        if let sessionToken = sessionToken,
            url == "\(APP_BASE_URL)/checkouts/success?token=\(sessionToken)" {
            AppLogger.instance("LabTestOrdering").info("Successful checkout!")
            showCheckoutPage = false
            showOrderConfirmation = true
        }
    }

    func toggleLabTestOrderModal() {
        self.showLabTestOrderModal.toggle()
    }

    func dismissLabTestOrderModal() {
        self.reset()
    }

    func reset() {
        showLabTestOrderModal = false
        showOrderConfirmation = false
        showCheckoutPage = false
        checkoutPageUrl = nil
        requiresAdditionalInformation = false
        requiredInformation = []
    }
}

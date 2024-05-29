import Foundation

class HealthProfileFormViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var healthProfile: HealthProfile?

    @Published var showErrorModal: Bool = false
    @Published var errorMessage: String = ""

    @Published var showSuccess: Bool = false

    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var sex: String = ""
    @Published var bloodType: String = ""
    @Published var dob: Date = Date().addingTimeInterval(-18 * 365 * 24 * 60 * 60) // Default to 18 years ago

    public func fetchHealthProfile() async throws {
        let data = try await apiCall(urlPath: "/health_profile", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(HealthProfile.self, from: data) {
            DispatchQueue.main.async {
                self.healthProfile = decodedResponse
            }
        }
    }

    public func updateHealthProfile(healthProfileData: [String: Any]? = [:]) async throws {
        let data = try await apiCall(urlPath: "/health_profile/update", method: "POST", requestData: healthProfileData)
        if let decodedResponse = try? JSONDecoder().decode(HealthProfile.self, from: data) {
            DispatchQueue.main.async {
                self.healthProfile = decodedResponse
            }
        }
    }

    public func submitForm() async {
        if firstName == "" || lastName == "" {
            DispatchQueue.main.async {
                self.showErrorModal = true
                self.errorMessage = "A first and last name is required."
            }
        } else if sex == "" {
            DispatchQueue.main.async {
                self.showErrorModal = true
                self.errorMessage = "Biological sex is required."
            }
        } else {
            Task {
                DispatchQueue.main.async {
                    self.isLoading = true
                }
                do {
                    try await updateHealthProfile(healthProfileData: [
                        "legal_first_name": firstName,
                        "legal_last_name": lastName,
                        "dob": dateToIsoString(dob),
                        "sex": sex,
                        "blood_type": bloodType
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

import Foundation

class RootViewModel: ObservableObject {
    /// If the user has already authorized something on the device, then don't show device onboarding. This is for existing users when this change first reaches their device.
    @Published var completedDeviceOnboarding: Bool = UserDefaults.standard.bool(forKey: HAS_COMPLETED_DEVICE_ONBOARDING_KEY) || UserDefaults.standard.bool(forKey: HAS_AUTHORIZED_HEALTH_KIT_KEY) || UserDefaults.standard.bool(forKey: HAS_AUTHORIZED_HEALTH_RECORDS_KEY)
    @Published var showSentinelOnboarding: Bool = false

    func completeUserOnboarding() async throws {
        _ = try await apiCall(urlPath: "/onboarding/completed", requestData: nil)
        UserDefaults.standard.set(true, forKey: HAS_COMPLETED_ONBOARDING_KEY)
        try await Session.shared.syncUser()

        DispatchQueue.main.async {
            self.completeDeviceOnboarding()
            self.showSentinelOnboarding = true
        }
    }

    public func resetOnboarding() async {
        do {
            _ = try await apiCall(urlPath: "/onboarding/reset", requestData: nil)
            try await Session.shared.syncUser()
            UserDefaults.standard.set(0, forKey: ONBOARDING_CURRENT_PAGE_KEY)
            UserDefaults.standard.set(false, forKey: HAS_COMPLETED_ONBOARDING_KEY)
            DispatchQueue.main.async {
                self.resetDeviceOnboarding()
                self.showSentinelOnboarding = false
            }
        } catch {
            AppLogger.instance("Networking").debug("Error resetting onboarding: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func completeDeviceOnboarding() {
        UserDefaults.standard.set(true, forKey: HAS_COMPLETED_DEVICE_ONBOARDING_KEY)
        self.completedDeviceOnboarding = true
    }

    public func resetDeviceOnboarding() {
        UserDefaults.standard.set(0, forKey: DEVICE_ONBOARDING_CURRENT_PAGE_KEY)
        UserDefaults.standard.set(false, forKey: HAS_COMPLETED_DEVICE_ONBOARDING_KEY)
        self.showSentinelOnboarding = false
        self.completedDeviceOnboarding = false
    }
}

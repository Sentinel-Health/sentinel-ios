import Foundation

class DeviceOnboardingViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var currentPage: Int

    init() {
        self.currentPage = UserDefaults.standard.integer(forKey: DEVICE_ONBOARDING_CURRENT_PAGE_KEY)
    }

    public func changeView(index: Int) {
        currentPage = index
        UserDefaults.standard.set(currentPage, forKey: DEVICE_ONBOARDING_CURRENT_PAGE_KEY)
    }

    public func nextView() {
        currentPage += 1
        UserDefaults.standard.set(currentPage, forKey: DEVICE_ONBOARDING_CURRENT_PAGE_KEY)
    }
}

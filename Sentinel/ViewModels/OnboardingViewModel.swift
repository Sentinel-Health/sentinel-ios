import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var currentPage: Int

    init() {
        self.currentPage = UserDefaults.standard.integer(forKey: ONBOARDING_CURRENT_PAGE_KEY)
    }

    public func changeView(index: Int) {
        currentPage = index
        UserDefaults.standard.set(currentPage, forKey: ONBOARDING_CURRENT_PAGE_KEY)
    }

    public func nextView() {
        currentPage += 1
        UserDefaults.standard.set(currentPage, forKey: ONBOARDING_CURRENT_PAGE_KEY)
    }

    public func confirmConsents(data: [String: Any]) async throws {
        _ = try await apiCall(urlPath: "/onboarding/consents/confirm", requestData: data)
    }

    public func saveHealthGoals(data: [String: Any]) async throws {
        _ = try await apiCall(urlPath: "/onboarding/health_goals", requestData: data)
    }
}

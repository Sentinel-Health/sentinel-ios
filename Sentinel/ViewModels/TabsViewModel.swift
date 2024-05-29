import Foundation

class TabsViewModel: ObservableObject {
    @Published var selectedTab: String = "overview"
    @Published var tabOptions: [String: Any] = [:]

    public func changeTab(_ tabName: String, options: [String: Any]? = [:]) {
        if let opts = options {
            tabOptions = opts
        }
        selectedTab = tabName
    }

    public func resetTabData() {
        tabOptions = [:]
    }
}

import Foundation

class LabTestOrdersViewModel: ObservableObject {
    @Published var orders: [LabTestOrder] = []

    public func fetchOrders(searchText: String? = nil) async throws {
        let data = try await apiCall(urlPath: "/lab_test_orders", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(LabTestOrdersResponse.self, from: data) {
            DispatchQueue.main.async {
                self.orders = decodedResponse.orders
            }
        }
    }
}

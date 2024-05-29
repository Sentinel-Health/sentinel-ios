import Foundation

class LabTestOrderResultsViewModel: ObservableObject {
    @Published var labTestOrder: LabTestOrder

    init(labTestOrder: LabTestOrder) {
        self.labTestOrder = labTestOrder
    }

    public func markViewed() async throws {
        let data = try await apiCall(urlPath: "/lab_test_orders/\(labTestOrder.id)/results/viewed", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(LabTestOrder.self, from: data) {
            DispatchQueue.main.async {
                self.labTestOrder = decodedResponse
            }
        }
    }
}

import Foundation
import SwiftUI

struct BiomarkerResponse: Codable {
    var biomarkerCategories: [BiomarkerCategory]
}

struct ConditionsResponse: Codable {
    var conditions: [Condition]
}

struct MedicationsResponse: Codable {
    var medications: [Medication]
}

struct AllergiesResponse: Codable {
    var allergies: [Allergy]
}

struct ImmunizationsResponse: Codable {
    var immunizations: [Immunization]
}

struct ProceduresResponse: Codable {
    var procedures: [Procedure]
}

struct LabTestsResponse: Codable {
    var unsupportedStates: [String] = []
    var tests: [LabTest]
}

struct LabTestOrdersResponse: Codable {
    var orders: [LabTestOrder]
}

class HomeViewModel: ObservableObject {
    @Published var sleepStats: SleepStats?

    @Published var fitnessStats: FitnessStats?

    @Published var bodyStats: BodyStats?

    @Published var biomarkers: [BiomarkerCategory] = []
    @Published var conditions: [Condition] = []
    @Published var medications: [Medication] = []
    @Published var allergies: [Allergy] = []
    @Published var immunizations: [Immunization] = []
    @Published var procedures: [Procedure] = []

    @Published var labTests: [LabTest] = []
    @Published var unsupportedLabTestStates: [String] = []
    @Published var labTestOrders: [LabTestOrder] = []

    @Published var isLoading: Bool = false
    @Published var kickOffResync: Bool = false

    public func fetchFitnessStats() async throws {
        let data = try await apiCall(urlPath: "/health_data/fitness_stats", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(FitnessStats.self, from: data) {
            DispatchQueue.main.async {
                self.fitnessStats = decodedResponse
            }
        }
    }

    public func fetchSleepStats() async throws {
        let data = try await apiCall(urlPath: "/health_data/sleep_stats", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(SleepStats.self, from: data) {
            DispatchQueue.main.async {
                self.sleepStats = decodedResponse
            }
        }
    }

    public func fetchBodyStats() async throws {
        let data = try await apiCall(urlPath: "/health_data/body_stats", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(BodyStats.self, from: data) {
            DispatchQueue.main.async {
                self.bodyStats = decodedResponse
            }
        }
    }

    public func fetchBiomarkers() async throws {
        let data = try await apiCall(urlPath: "/biomarkers", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(BiomarkerResponse.self, from: data) {
            DispatchQueue.main.async {
                self.biomarkers = decodedResponse.biomarkerCategories
            }
        }
    }

    public func fetchConditions() async throws {
        let data = try await apiCall(urlPath: "/conditions", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(ConditionsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.conditions = decodedResponse.conditions
            }
        }
    }

    public func fetchMedications() async throws {
        let data = try await apiCall(urlPath: "/medications", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(MedicationsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.medications = decodedResponse.medications
            }
        }
    }

    public func fetchAllergies() async throws {
        let data = try await apiCall(urlPath: "/allergies", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(AllergiesResponse.self, from: data) {
            DispatchQueue.main.async {
                self.allergies = decodedResponse.allergies
            }
        }
    }

    public func fetchImmunizations() async throws {
        let data = try await apiCall(urlPath: "/immunizations", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(ImmunizationsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.immunizations = decodedResponse.immunizations
            }
        }
    }

    public func fetchProcedures() async throws {
        let data = try await apiCall(urlPath: "/procedures", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(ProceduresResponse.self, from: data) {
            DispatchQueue.main.async {
                self.procedures = decodedResponse.procedures
            }
        }
    }

    public func fetchLabTests() async throws {
        let data = try await apiCall(urlPath: "/lab_tests", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(LabTestsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.unsupportedLabTestStates = decodedResponse.unsupportedStates
                self.labTests = decodedResponse.tests
            }
        }
    }

    public func fetchLabTestOrders() async throws {
        let data = try await apiCall(urlPath: "/lab_test_orders?active_or_not_viewed=true", method: "GET", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(LabTestOrdersResponse.self, from: data) {
            DispatchQueue.main.async {
                self.labTestOrders = decodedResponse.orders
            }
        }
    }

    public func archiveMedication(_ medicationId: String) async throws {
        DispatchQueue.main.async {
            withAnimation {
                self.medications.removeAll(where: { $0.id == medicationId })
            }
        }

        let data = try await apiCall(urlPath: "/medications/\(medicationId)/archive", method: "POST", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(MedicationsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.medications = decodedResponse.medications
            }
        }
    }

    public func archiveCondition(_ conditionId: String) async throws {
        DispatchQueue.main.async {
            withAnimation {
                self.conditions.removeAll(where: { $0.id == conditionId })
            }
        }

        let data = try await apiCall(urlPath: "/conditions/\(conditionId)/archive", method: "POST", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(ConditionsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.conditions = decodedResponse.conditions
            }
        }
    }

    public func archiveAllergy(_ allergyId: String) async throws {
        DispatchQueue.main.async {
            withAnimation {
                self.allergies.removeAll(where: { $0.id == allergyId })
            }
        }

        let data = try await apiCall(urlPath: "/allergies/\(allergyId)/archive", method: "POST", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(AllergiesResponse.self, from: data) {
            DispatchQueue.main.async {
                self.allergies = decodedResponse.allergies
            }
        }
    }

    public func archiveImmunization(_ immunizationId: String) async throws {
        DispatchQueue.main.async {
            withAnimation {
                self.immunizations.removeAll(where: { $0.id == immunizationId })
            }
        }

        let data = try await apiCall(urlPath: "/immunizations/\(immunizationId)/archive", method: "POST", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(ImmunizationsResponse.self, from: data) {
            DispatchQueue.main.async {
                self.immunizations = decodedResponse.immunizations
            }
        }
    }

    public func archiveProcedure(_ procedureId: String) async throws {
        DispatchQueue.main.async {
            withAnimation {
                self.procedures.removeAll(where: { $0.id == procedureId })
            }
        }

        let data = try await apiCall(urlPath: "/procedures/\(procedureId)/archive", method: "POST", requestData: nil)
        if let decodedResponse = try? JSONDecoder().decode(ProceduresResponse.self, from: data) {
            DispatchQueue.main.async {
                self.procedures = decodedResponse.procedures
            }
        }
    }
}

import Foundation
import SwiftUI

class VerifyRecordsViewModel: ObservableObject {
    @Published var conditions: [Condition] = []
    @Published var medications: [Medication] = []
    @Published var allergies: [Allergy] = []
    @Published var immunizations: [Immunization] = []
    @Published var procedures: [Procedure] = []

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

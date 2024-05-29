import Foundation
import HealthKit

import ModelsDSTU2
import ModelsR4

struct LabResultData: Identifiable, Codable, Hashable {
    static func == (lhs: LabResultData, rhs: LabResultData) -> Bool {
        lhs.id == rhs.id
    }

    var id: String?
    var date: Date?
    var label: String?
    var value: Double?
    var unit: String?
    var referenceRange: LabResultDataReferenceRange?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
        hasher.combine(label)
        hasher.combine(value)
        hasher.combine(unit)
        hasher.combine(referenceRange)
    }
}

struct LabResultDataReferenceRange: Codable, Hashable {
    var highValue: Double?
    var highUnit: String?
    var lowValue: Double?
    var lowUnit: String?
    var text: String?
}

enum FHIRResourceDecodingError: Error {
    case notAnHKClinicalRecord(HKSample)
    case noFHIRResourcePresent(HKClinicalRecord)
    case resourceTypeNotSupported(HKFHIRResourceType)
    case versionNotSupported(String)
}

/// Each clincal record retrieved from HealthKit is associated with a FHIR Resource. Decode it using the FHIRModels.
func decodeClinicalRecord(resource: HKFHIRResource) {
    do {
        switch resource.fhirVersion.fhirRelease {
        case .dstu2:
            try decodeDSTU2(resource: resource)
        case .r4:
            try decodeR4(resource: resource)
        default:
            AppLogger.instance("FHIRData").info("unknown or unsupported release")
            /// iOS supported DSTU2 for all records at an earlier time
            try decodeDSTU2(resource: resource)
        }
    } catch {
        AppLogger.instance("FHIRData").error("unable to decode resource: \(resource.fhirVersion.stringRepresentation, privacy: .public)")
        return
    }
}

func decodeLabResult(resource: HKFHIRResource) -> LabResultData? {
    let decoder = JSONDecoder()

    do {
        switch resource.fhirVersion.fhirRelease {
        case .dstu2:
            let observation = try decoder.decode(ModelsDSTU2.Observation.self, from: resource.data)
            return getDSTU2Observation(observation: observation)
        case .r4:
            let observation = try decoder.decode(ModelsR4.Observation.self, from: resource.data)
            return getR4Observation(observation: observation)
        default:
            AppLogger.instance("FHIRData").info("unknown or unsupported release")
            /// iOS supported DSTU2 for all records at an earlier time
            let observation = try decoder.decode(ModelsDSTU2.Observation.self, from: resource.data)
            return getDSTU2Observation(observation: observation)
        }
    } catch {
        AppLogger.instance("FHIRData").error("unable to decode resource: \(resource.fhirVersion.stringRepresentation, privacy: .public)")
        return nil
    }
}

/// Decode FHIR resources using ModelsDSTU2
func decodeDSTU2(resource: HKFHIRResource) throws {
    let decoder = JSONDecoder()

    switch resource.resourceType {
    case .allergyIntolerance:
        _ = try decoder.decode(ModelsDSTU2.AllergyIntolerance.self, from: resource.data)
    case .condition:
        _ = try decoder.decode(ModelsDSTU2.Condition.self, from: resource.data)
    case .immunization:
        _ = try decoder.decode(ModelsDSTU2.Immunization.self, from: resource.data)
    case .medicationDispense:
        _ = try decoder.decode(ModelsDSTU2.MedicationDispense.self, from: resource.data)
    case .medicationOrder:
        _ = try decoder.decode(ModelsDSTU2.MedicationOrder.self, from: resource.data)
    case .medicationStatement:
        _ = try decoder.decode(ModelsDSTU2.MedicationStatement.self, from: resource.data)
    case .observation:
        let observation = try decoder.decode(ModelsDSTU2.Observation.self, from: resource.data)
        _ = getDSTU2Observation(observation: observation)
    case .procedure:
        _ = try decoder.decode(ModelsDSTU2.Procedure.self, from: resource.data)
    default:
        throw FHIRResourceDecodingError.resourceTypeNotSupported(resource.resourceType)
    }
}

/// Decode FHIR resources using the ModelsR4 encoding.
func decodeR4(resource: HKFHIRResource) throws {
    let decoder = JSONDecoder()

    switch resource.resourceType {
    case .allergyIntolerance:
        _ = try decoder.decode(ModelsR4.AllergyIntolerance.self, from: resource.data)
    case .condition:
        _ = try decoder.decode(ModelsR4.Condition.self, from: resource.data)
    case .immunization:
        _ = try decoder.decode(ModelsR4.Immunization.self, from: resource.data)
    case .medicationDispense:
        _ = try decoder.decode(ModelsR4.MedicationDispense.self, from: resource.data)
    case .medicationRequest:
        _ = try decoder.decode(ModelsR4.MedicationRequest.self, from: resource.data)
    case .medicationStatement:
        _ = try decoder.decode(ModelsR4.MedicationStatement.self, from: resource.data)
    case .observation:
        let observation = try decoder.decode(ModelsR4.Observation.self, from: resource.data)
        _ = getR4Observation(observation: observation)
    case .procedure:
        _ = try decoder.decode(ModelsR4.Procedure.self, from: resource.data)
    default:
        throw FHIRResourceDecodingError.resourceTypeNotSupported(resource.resourceType)
    }
}

func getR4Observation(observation: ModelsR4.Observation) -> LabResultData? {
    var observationResult: LabResultData = LabResultData()
    observationResult.id = observation.id?.value?.string

    if let label = observation.code.text?.value?.string {
        observationResult.label = label
    } else if let label = observation.code.coding?.first?.display?.value?.string {
        observationResult.label = label
    }

    if let observationDate = observation.issued?.value?.date {
        var dateComponents = DateComponents()
        dateComponents.day = Int(observationDate.day)
        dateComponents.month = Int(observationDate.month)
        dateComponents.year = observationDate.year
        observationResult.date = Calendar.current.date(from: dateComponents)
    }

    switch observation.value {
    case .quantity(let quantity):
        if let decimalValue = quantity.value?.value?.decimal as? Decimal {
            let doubleValue = Double(truncating: decimalValue as NSNumber)
            observationResult.value = doubleValue
        }
        observationResult.unit = quantity.unit?.value?.string
    case .codeableConcept(let codeableConcept):
        // handle codeableConcept
        print("Lab Result Value: \(codeableConcept.text ?? "")")
    case .string(let string):
        // handle string
        print("Lab Result Value: \(string.value?.string ?? "")")
    case .boolean(let bool):
        // handle boolean
        print("Lab Result Value: \(bool.value?.bool ?? false)")
    case .integer(let integer):
        // handle integer
        print("Lab Result Value: \(integer.value?.integer ?? 0)")
    case .range(let range):
        // handle range
        print("Lab Result Value: \(range.high?.value?.value?.decimal ?? 0.0) - \(range.low?.value?.value?.decimal ?? 0.0)")
    case .ratio(let ratio):
        // handle ratio
        print("Lab Result Value: \(ratio.numerator?.value?.value?.decimal ?? 0.0) / \(ratio.denominator?.value?.value?.decimal ?? 0.0)")
    case .sampledData(let sampledData):
        // handle sampledData
        print("Lab Result Value: \(sampledData.data?.value?.string ?? "")")
    case .time(let time):
        // handle time
        print("Lab Result Value: \(time.value?.hour ?? 0):\(time.value?.minute ?? 00)")
    case .dateTime(let dateTime):
        // handle dateTime
        print("Lab Result Value: \(dateTime.value?.date ?? "")")
    case .period(let period):
        // handle period
        print("Lab Result Value: \(period.start?.value?.date ?? "") - \(period.end?.value?.date ?? "")")
    default:
        print("obvervation value type unknown: \(observation.value.debugDescription)")
    }

    if let referenceRange = observation.referenceRange {
        if let reference = referenceRange.first {
            var range = LabResultDataReferenceRange()

            if let highDecimalValue = reference.high?.value?.value?.decimal as? Decimal {
                let doubleValue = Double(truncating: highDecimalValue as NSNumber)
                range.highValue = doubleValue
            }
            if let lowDecimalValue = reference.low?.value?.value?.decimal as? Decimal {
                let doubleValue = Double(truncating: lowDecimalValue as NSNumber)
                range.lowValue = doubleValue
            }
            range.highUnit = reference.high?.unit?.value?.string
            range.lowUnit = reference.low?.unit?.value?.string
            range.text = reference.text?.value?.string

            observationResult.referenceRange = range
        }
    }

    return observationResult
}

func getDSTU2Observation(observation: ModelsDSTU2.Observation) -> LabResultData? {
    var observationResult: LabResultData = LabResultData()
    observationResult.id = observation.id?.value?.string

    if let label = observation.code.text?.value?.string {
        observationResult.label = label
    } else if let label = observation.code.coding?.first?.display?.value?.string {
        observationResult.label = label
    }

    if let observationDate = observation.issued?.value?.date {
        var dateComponents = DateComponents()
        dateComponents.day = Int(observationDate.day)
        dateComponents.month = Int(observationDate.month)
        dateComponents.year = observationDate.year
        observationResult.date = Calendar.current.date(from: dateComponents)
    }

    switch observation.value {
    case .quantity(let quantity):
        if let decimalValue = quantity.value?.value?.decimal as? Decimal {
            let doubleValue = Double(truncating: decimalValue as NSNumber)
            observationResult.value = doubleValue
        }
        observationResult.unit = quantity.unit?.value?.string
    case .codeableConcept(let codeableConcept):
        // handle codeableConcept
        print("Lab Result Value: \(codeableConcept.text ?? "")")
    case .string(let string):
        // handle string
        print("Lab Result Value: \(string.value?.string ?? "")")
    case .range(let range):
        // handle range
        print("Lab Result Value: \(range.high?.value?.value?.decimal ?? 0.0) - \(range.low?.value?.value?.decimal ?? 0.0)")
    case .ratio(let ratio):
        // handle ratio
        print("Lab Result Value: \(ratio.numerator?.value?.value?.decimal ?? 0.0) / \(ratio.denominator?.value?.value?.decimal ?? 0.0)")
    case .sampledData(let sampledData):
        // handle sampledData
        print("Lab Result Value: \(sampledData.data.value?.string ?? "")")
    case .time(let time):
        // handle time
        print("Lab Result Value: \(time.value?.hour ?? 0):\(time.value?.minute ?? 00)")
    case .dateTime(let dateTime):
        // handle dateTime
        print("Lab Result Value: \(dateTime.value?.date ?? "")")
    case .period(let period):
        // handle period
        print("Lab Result Value: \(period.start?.value?.date ?? "") - \(period.end?.value?.date ?? "")")
    default:
        print("obvervation value type unknown: \(observation.value.debugDescription)")
    }

    if let referenceRange = observation.referenceRange {
        for reference in referenceRange {
            var range = LabResultDataReferenceRange()

            if let highDecimalValue = reference.high?.value?.value?.decimal as? Decimal {
                let doubleValue = Double(truncating: highDecimalValue as NSNumber)
                range.highValue = doubleValue
            }
            range.highUnit = reference.high?.unit?.value?.string
            if let lowDecimalValue = reference.low?.value?.value?.decimal as? Decimal {
                let doubleValue = Double(truncating: lowDecimalValue as NSNumber)
                range.lowValue = doubleValue
            }
            range.lowUnit = reference.low?.unit?.value?.string

            observationResult.referenceRange = range
        }
    }

    return observationResult
}

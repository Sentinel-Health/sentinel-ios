import Foundation
import HealthKit

let _dateFormatter = ISO8601DateFormatter()

func serializeHealthProfile(healthProfile: HealthProfile) -> [String: Any] {
    return [
        "legal_first_name": healthProfile.legalFirstName ?? "",
        "legal_last_name": healthProfile.legalLastName ?? "",
        "sex": healthProfile.sex ?? "",
        "blood_type": healthProfile.bloodType ?? "",
        "skin_type": healthProfile.skinType ?? "",
        "wheelchair_use": healthProfile.wheelchairUse ?? "",
        "dob": healthProfile.dob ?? ""
    ]
}

func serializeMessageDataForRequest(message: Message) -> [String: Any] {
    return [
        "role": message.role,
        "content": message.content!
    ]
}

func serializeQuantity(unit: HKUnit, quantity: HKQuantity?) -> [String: Any]? {
    guard let q = quantity else {
        return nil
    }

    return [
        "quantity": q.doubleValue(for: unit),
        "unit": unit.unitString
    ]
}

func serializeQuantitySample(sample: HKQuantitySample, unit: HKUnit) -> NSDictionary {
    let endDate = _dateFormatter.string(from: sample.endDate)
    let startDate = _dateFormatter.string(from: sample.startDate)

    let quantity = sample.quantity.doubleValue(for: unit)

    return [
        "uuid": sample.uuid.uuidString,
        "device": serializeDevice(_device: sample.device) as Any,
        "quantityType": sample.quantityType.identifier,
        "endDate": endDate,
        "startDate": startDate,
        "quantity": quantity,
        "unit": unit.unitString,
        "metadata": serializeMetadata(metadata: sample.metadata),
        "sourceRevision": serializeSourceRevision(_sourceRevision: sample.sourceRevision) as Any
    ]
}

func serializeQuantitySummaryData(date: Date, quantity: Double, quantityType: HKQuantityType, unit: HKUnit, summaryType: String) -> NSDictionary {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    let dateString = formatter.string(from: date)

    return [
        "quantityType": quantityType.identifier,
        "summaryType": summaryType,
        "date": dateString,
        "quantity": quantity,
        "unit": unit.unitString
    ]
}

func serializeDeletedSample(sample: HKDeletedObject) -> NSDictionary {
    return [
        "uuid": sample.uuid.uuidString,
        "metadata": serializeMetadata(metadata: sample.metadata)
    ]
}

func serializeCategorySample(sample: HKCategorySample) -> NSDictionary {
    let endDate = _dateFormatter.string(from: sample.endDate)
    let startDate = _dateFormatter.string(from: sample.startDate)

    return [
        "uuid": sample.uuid.uuidString,
        "device": serializeDevice(_device: sample.device) as Any,
        "categoryType": sample.categoryType.identifier,
        "endDate": endDate,
        "startDate": startDate,
        "value": sample.value,
        "metadata": serializeMetadata(metadata: sample.metadata),
        "sourceRevision": serializeSourceRevision(_sourceRevision: sample.sourceRevision) as Any
    ]
}

func serializeSource(source: HKSource) -> NSDictionary {

    return [
        "bundleIdentifier": source.bundleIdentifier,
        "name": source.name
    ]
}

func serializeFHIRData(resource: HKFHIRResource) -> Any {
    do {
        let data = try JSONSerialization.jsonObject(with: resource.data, options: [])
        return data
    } catch {
        let errorMessage = "*** An error occurred while parsing the FHIR data: \(error.localizedDescription) ***"
        AppLogger.instance().error("Error: \(errorMessage, privacy: .public)")
        return []
    }
}

func serializeClinicalRecord(record: HKClinicalRecord) -> NSDictionary {
    let endDate = _dateFormatter.string(from: record.endDate)
    let startDate = _dateFormatter.string(from: record.startDate)

    var dict = [
        "uuid": record.uuid.uuidString,
        "device": serializeDevice(_device: record.device) as Any,
        "clinicalType": record.clinicalType.identifier,
        "endDate": endDate,
        "startDate": startDate,
        "displayName": record.displayName,
        "sourceRevision": serializeSourceRevision(_sourceRevision: record.sourceRevision) as Any
    ]
    if let fhirResource = record.fhirResource {
        let data = serializeFHIRData(resource: fhirResource)
        dict.updateValue(fhirResource.fhirVersion.fhirRelease.rawValue, forKey: "fhirRelease")
        dict.updateValue(fhirResource.fhirVersion.stringRepresentation, forKey: "fhirVersion")
        dict.updateValue(data, forKey: "fhirData")
    }

    return dict as NSDictionary
}

func serializeWorkout(workout: HKWorkout) -> NSDictionary {
    let endDate = _dateFormatter.string(from: workout.endDate)
    let startDate = _dateFormatter.string(from: workout.startDate)

    // TODO: get preferred units here
    let energyUnit = HKUnit.init(from: .kilocalorie)
    let distanceUnit = HKUnit.init(from: .mile)

    let dict: NSMutableDictionary = [
        "uuid": workout.uuid.uuidString,
        "device": serializeDevice(_device: workout.device) as Any,
        "duration": workout.duration,
        "durationUnit": HKUnit.second().unitString,
        "totalDistance": serializeQuantity(unit: distanceUnit, quantity: workout.totalDistance) as Any,
        "totalEnergyBurned": serializeQuantity(unit: energyUnit, quantity: workout.totalEnergyBurned) as Any,
        "totalSwimmingStrokeCount": serializeQuantity(unit: HKUnit.count(), quantity: workout.totalSwimmingStrokeCount) as Any,
        "workoutActivityType": workout.workoutActivityType.rawValue,
        "startDate": startDate,
        "endDate": endDate,
        "metadata": serializeMetadata(metadata: workout.metadata),
        "sourceRevision": serializeSourceRevision(_sourceRevision: workout.sourceRevision) as Any
    ]

    // this is used for our laps functionality to get markers
    // https://developer.apple.com/documentation/healthkit/hkworkoutevent
    var eventArray: [[String: Any]] = []
    if let events = workout.workoutEvents {
        for event in events {
            let eventStartDate = _dateFormatter.string(from: event.dateInterval.start)
            let eventEndDate = _dateFormatter.string(from: event.dateInterval.end)
            let eventDict: [String: Any] = [
                "type": event.type.rawValue, // https://developer.apple.com/documentation/healthkit/hkworkouteventtype
                "startDate": eventStartDate,
                "endDate": eventEndDate
            ]
            eventArray.append(eventDict)
        }
    }
    dict["events"] = eventArray

    // also used for our laps functionality to get activities for custom workouts defined by the user
    // https://developer.apple.com/documentation/healthkit/hkworkout/1615340-init
    // it seems this might be depricated in the latest beta so this might need updating!
    var activitiesArray: [[String: Any]] = []
    let activities: [HKWorkoutActivity] = workout.workoutActivities

    if !activities.isEmpty {
        for activity in activities {
            var activityStartDate = ""
            var activityEndDate = ""
            if let start = activity.startDate as Date? {
                activityStartDate = _dateFormatter.string(from: start)
            }
            if let end = activity.endDate as Date? {
                activityEndDate = _dateFormatter.string(from: end)
            }
            let activityDict: [String: Any] = [
                "startDate": activityStartDate,
                "endDate": activityEndDate,
                "uuid": activity.uuid.uuidString,
                "duration": activity.duration
            ]
            activitiesArray.append(activityDict)
        }
    }
    dict["activities"] = activitiesArray
    dict.setValue(serializeQuantity(unit: HKUnit.count(), quantity: workout.totalFlightsClimbed), forKey: "totalFlightsClimbed")

    return dict as NSDictionary
}

func serializeUnknownQuantity(quantity: HKQuantity) -> [String: Any]? {
    if quantity.is(compatibleWith: HKUnit.percent()) {
        return serializeQuantity(unit: HKUnit.percent(), quantity: quantity)
    }

    if quantity.is(compatibleWith: HKUnit.second()) {
        return serializeQuantity(unit: HKUnit.second(), quantity: quantity)
    }

    if quantity.is(compatibleWith: HKUnit.kilocalorie()) {
        return serializeQuantity(unit: HKUnit.kilocalorie(), quantity: quantity)
    }

    if quantity.is(compatibleWith: HKUnit.count()) {
        return serializeQuantity(unit: HKUnit.count(), quantity: quantity)
    }

    if quantity.is(compatibleWith: HKUnit.meter()) {
        return serializeQuantity(unit: HKUnit.meter(), quantity: quantity)
    }

    if #available(iOS 11, *) {
        if quantity.is(compatibleWith: HKUnit.internationalUnit()) {
            return serializeQuantity(unit: HKUnit.internationalUnit(), quantity: quantity)
        }
    }

    if #available(iOS 13, *) {
        if quantity.is(compatibleWith: HKUnit.hertz()) {
            return serializeQuantity(unit: HKUnit.hertz(), quantity: quantity)
        }
        if quantity.is(compatibleWith: HKUnit.decibelHearingLevel()) {
            return serializeQuantity(unit: HKUnit.decibelHearingLevel(), quantity: quantity)
        }
    }

    if quantity.is(compatibleWith: SpeedUnit) {
        return serializeQuantity(unit: SpeedUnit, quantity: quantity)
    }

    if quantity.is(compatibleWith: METUnit) {
        return serializeQuantity(unit: METUnit, quantity: quantity)
    }

    return nil
}

func serializeMetadata(metadata: [String: Any]?) -> NSDictionary {
    let serialized: NSMutableDictionary = [:]
    if let m = metadata {
        for item in m {
            if let bool = item.value as? Bool {
                serialized.setValue(bool, forKey: item.key)
            }
            if let str = item.value as? String {
                serialized.setValue(str, forKey: item.key)
            }

            if let double = item.value as? Double {
                serialized.setValue(double, forKey: item.key)
            }
            if let quantity = item.value as? HKQuantity {
                if let s = serializeUnknownQuantity(quantity: quantity) {
                    serialized.setValue(s, forKey: item.key)
                }
            }
        }
    }
    return serialized
}

func serializeDevice(_device: HKDevice?) -> [String: String?]? {
    guard let device = _device else {
        return nil
    }

    return [
        "name": device.name,
        "firmwareVersion": device.firmwareVersion,
        "hardwareVersion": device.hardwareVersion,
        "localIdentifier": device.localIdentifier,
        "manufacturer": device.manufacturer,
        "model": device.model,
        "softwareVersion": device.softwareVersion,
        "udiDeviceIdentifier": device.udiDeviceIdentifier
    ]
}

func serializeOperatingSystemVersion(_version: OperatingSystemVersion?) -> String? {
    guard let version = _version else {
        return nil
    }

    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

    return versionString
}

func serializeSourceRevision(_sourceRevision: HKSourceRevision?) -> [String: Any?]? {
    guard let sourceRevision = _sourceRevision else {
        return nil
    }

    var dict = [
        "source": [
            "name": sourceRevision.source.name,
            "bundleIdentifier": sourceRevision.source.bundleIdentifier
        ],
        "version": sourceRevision.version as Any
    ] as [String: Any]

    if #available(iOS 11, *) {
        dict["operatingSystemVersion"] = serializeOperatingSystemVersion(_version: sourceRevision.operatingSystemVersion)
        dict["productType"] = sourceRevision.productType
    }

    return dict
}

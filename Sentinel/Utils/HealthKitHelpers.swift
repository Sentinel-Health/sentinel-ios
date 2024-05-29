import Foundation
import HealthKit

func dateOrNilIfZero(date: Date) -> Date? {
    return date.timeIntervalSince1970 > 0 ? date : nil
}

func limitOrNilIfZero(limit: Int) -> Int {
    return limit == 0 ? HKObjectQueryNoLimit : limit
}

func createPredicate(from: Date?, to: Date?) -> NSPredicate? {
    if from != nil || to != nil {
        return HKQuery.predicateForSamples(withStart: from, end: to, options: [.strictEndDate, .strictStartDate])
    } else {
        return nil
    }
}

func getSortDescriptors(ascending: Bool) -> [NSSortDescriptor] {
    return [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: ascending)]
}

func sampleTypeFromString(typeIdentifier: String) -> HKSampleType? {
    if typeIdentifier.starts(with: HKQuantityTypeIdentifier_PREFIX) {
        let identifier = HKQuantityTypeIdentifier.init(rawValue: typeIdentifier)
        return HKSampleType.quantityType(forIdentifier: identifier) as HKSampleType?
    }

    if typeIdentifier.starts(with: HKCategoryTypeIdentifier_PREFIX) {
        let identifier = HKCategoryTypeIdentifier.init(rawValue: typeIdentifier)
        return HKSampleType.categoryType(forIdentifier: identifier) as HKSampleType?
    }

    if typeIdentifier.starts(with: HKCorrelationTypeIdentifier_PREFIX) {
        let identifier = HKCorrelationTypeIdentifier.init(rawValue: typeIdentifier)
        return HKSampleType.correlationType(forIdentifier: identifier) as HKSampleType?
    }

    if typeIdentifier.starts(with: HKDocumentTypeIdentifier_PREFIX) {
        let identifier = HKDocumentTypeIdentifier.init(rawValue: typeIdentifier)
        return HKSampleType.documentType(forIdentifier: identifier) as HKSampleType?
    }

    if #available(iOS 12, *) {
        if typeIdentifier.starts(with: HKClinicalTypeIdentifier_PREFIX) {
            let identifier = HKClinicalTypeIdentifier.init(rawValue: typeIdentifier)
            return HKSampleType.clinicalType(forIdentifier: identifier) as HKSampleType?
        }
    }

    if #available(iOS 13, *) {
        if typeIdentifier == HKAudiogramTypeIdentifier {
            return HKSampleType.audiogramSampleType()
        }
    }

    if typeIdentifier == HKWorkoutTypeIdentifier {
        return HKSampleType.workoutType()
    }

    if #available(iOS 11.0, *) {
        if typeIdentifier == HKWorkoutRouteTypeIdentifier {
            return HKObjectType.seriesType(forIdentifier: typeIdentifier)
        }
    }

    return nil
}

func quantityTypeFromString(typeIdentifier: String) -> HKQuantityType? {
    if typeIdentifier.starts(with: HKQuantityTypeIdentifier_PREFIX) {
        let identifier = HKQuantityTypeIdentifier.init(rawValue: typeIdentifier)
        return HKSampleType.quantityType(forIdentifier: identifier) as HKQuantityType?
    }

    return nil
}

func objectTypesFromDictionary(typeIdentifiers: NSDictionary) -> Set<HKObjectType> {
    var share = Set<HKObjectType>()
    for item in typeIdentifiers {
        if item.value as! Bool {
            let objectType = objectTypeFromString(typeIdentifier: item.key as! String)
            if objectType != nil {
                share.insert(objectType!)
            }
        }
    }
    return share
}

func sampleTypesFromDictionary(typeIdentifiers: NSDictionary) -> Set<HKSampleType> {
    var share = Set<HKSampleType>()
    for item in typeIdentifiers {
        if item.value as! Bool {
            let sampleType = sampleTypeFromString(typeIdentifier: item.key as! String)
            if sampleType != nil {
             share.insert(sampleType!)
            }
        }
    }
    return share
}

func objectTypeFromString(typeIdentifier: String) -> HKObjectType? {
    if typeIdentifier.starts(with: HKCharacteristicTypeIdentifier_PREFIX) {
        let identifier = HKCharacteristicTypeIdentifier.init(rawValue: typeIdentifier)
        return HKObjectType.characteristicType(forIdentifier: identifier) as HKObjectType?
    }

    if typeIdentifier.starts(with: HKQuantityTypeIdentifier_PREFIX) {
        let identifier = HKQuantityTypeIdentifier.init(rawValue: typeIdentifier)
        return HKObjectType.quantityType(forIdentifier: identifier) as HKObjectType?
    }

    if typeIdentifier.starts(with: HKCategoryTypeIdentifier_PREFIX) {
        let identifier = HKCategoryTypeIdentifier.init(rawValue: typeIdentifier)
        return HKObjectType.categoryType(forIdentifier: identifier) as HKObjectType?
    }

    if typeIdentifier.starts(with: HKCorrelationTypeIdentifier_PREFIX) {
        let identifier = HKCorrelationTypeIdentifier.init(rawValue: typeIdentifier)
        return HKObjectType.correlationType(forIdentifier: identifier) as HKObjectType?
    }

    if typeIdentifier.starts(with: HKDocumentTypeIdentifier_PREFIX) {
        let identifier = HKDocumentTypeIdentifier.init(rawValue: typeIdentifier)
        return HKObjectType.documentType(forIdentifier: identifier) as HKObjectType?
    }

    if #available(iOS 12, *) {
        if typeIdentifier.starts(with: HKClinicalTypeIdentifier_PREFIX) {
            let identifier = HKClinicalTypeIdentifier.init(rawValue: typeIdentifier)
            return HKObjectType.clinicalType(forIdentifier: identifier) as HKObjectType?
        }
    }

    if typeIdentifier == HKActivitySummaryTypeIdentifier {
        return HKObjectType.activitySummaryType()
    }

    if #available(iOS 13, *) {
        if typeIdentifier == HKAudiogramTypeIdentifier {
            return HKObjectType.audiogramSampleType()
        }

        if typeIdentifier == HKDataTypeIdentifierHeartbeatSeries {
            return HKObjectType.seriesType(forIdentifier: typeIdentifier)
        }
    }

    if typeIdentifier == HKWorkoutTypeIdentifier {
        return HKObjectType.workoutType()
    }

    if #available(iOS 11.0, *) {
        if typeIdentifier == HKWorkoutRouteTypeIdentifier {
            return HKObjectType.seriesType(forIdentifier: typeIdentifier)
        }
    }

    return nil
}

func getPreferredUnits(forTypes: [HKQuantityType], store: HKHealthStore) async throws -> NSMutableDictionary {
    var quantityTypes = Set<HKQuantityType>()
    for type in forTypes {
        quantityTypes.insert(type)
    }

    let typePerUnits: [HKQuantityType: HKUnit] = try await store.preferredUnits(for: quantityTypes)

    let dic = NSMutableDictionary()

    for typePerUnit in typePerUnits {
        dic.setObject(typePerUnit.value.unitString, forKey: typePerUnit.key.identifier as NSCopying)
    }

    return dic
}

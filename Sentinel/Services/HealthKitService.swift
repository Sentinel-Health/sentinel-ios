import Foundation
import HealthKit
import Combine
import UIKit

enum HealthKitError: String, Error {
    case initialization = "Initializing failed."
    case unavailable = "HealthKit is unavailable on this device."
    case permissions = "Permissions were not granted."
    case protectedDataUnavailable = "Protected data unavailable."
}

private class FailedSyncStorage {

    public static let shared = FailedSyncStorage()

    private init() {

    }

    func getMinStartDate(_ givenDate: Date?) -> Date {
        let timeIntervalSince1970 = UserDefaults.standard.double(forKey: LAST_FAILED_HEALTH_KIT_SYNC_DATE)
        guard timeIntervalSince1970 > 0 else {
            return givenDate ?? Date()
        }

        guard let givenDate else {
            return Date(timeIntervalSince1970: timeIntervalSince1970)
        }

        let minimumTimeInterval = min(givenDate.timeIntervalSince1970, timeIntervalSince1970)

        return Date(timeIntervalSince1970: minimumTimeInterval)
    }

    func storeFailedDate(_ date: Date) {
        let savedTimeIntervalSince1970 = UserDefaults.standard.double(forKey: LAST_FAILED_HEALTH_KIT_SYNC_DATE)

        // if the given date is before saved date, then don't save it
        guard savedTimeIntervalSince1970 > date.timeIntervalSince1970 else { return }

        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: LAST_FAILED_HEALTH_KIT_SYNC_DATE)
    }

    func onSuccess(_ startDate: Date) {
        let savedTimeIntervalSince1970 = UserDefaults.standard.double(forKey: LAST_FAILED_HEALTH_KIT_SYNC_DATE)
        guard savedTimeIntervalSince1970 > 0 else { return }

        if startDate.timeIntervalSince1970 <= savedTimeIntervalSince1970 {
            UserDefaults.standard.set(nil, forKey: LAST_FAILED_HEALTH_KIT_SYNC_DATE)
        }
    }

}

enum HealthData {
    case clinicalRecords
    case quantitySamples
    case categorySamples
    case characteristics
    case workoutData

    var identifierStrings: [String] {
        switch self {
        case .clinicalRecords:
            return [
                HKClinicalTypeIdentifier.allergyRecord.rawValue,
                HKClinicalTypeIdentifier.clinicalNoteRecord.rawValue,
                HKClinicalTypeIdentifier.conditionRecord.rawValue,
                HKClinicalTypeIdentifier.coverageRecord.rawValue,
                HKClinicalTypeIdentifier.immunizationRecord.rawValue,
                HKClinicalTypeIdentifier.labResultRecord.rawValue,
                HKClinicalTypeIdentifier.medicationRecord.rawValue,
                HKClinicalTypeIdentifier.procedureRecord.rawValue,
                HKClinicalTypeIdentifier.vitalSignRecord.rawValue
            ]

        case .quantitySamples:
            return [
                // Activity
                HKQuantityTypeIdentifier.stepCount.rawValue,
                // Body
                // HKQuantityTypeIdentifier.bodyTemperature.rawValue, // degC, Discrete (Arithmetic)
                HKQuantityTypeIdentifier.bodyFatPercentage.rawValue, // %, Discrete (Arithmetic)
                HKQuantityTypeIdentifier.bodyMass.rawValue, // kg, Discrete (Arithmetic)
                HKQuantityTypeIdentifier.bodyMassIndex.rawValue, // count, Discrete (Arithmetic)
                HKQuantityTypeIdentifier.height.rawValue, // m, Discrete (Arithmetic)
                // HKQuantityTypeIdentifier.leanBodyMass.rawValue, // kg, Discrete (Arithmetic)
                // HKQuantityTypeIdentifier.waistCircumference.rawValue, // m, Discrete (Arithmetic)
                // Heart
                // HKQuantityTypeIdentifier.atrialFibrillationBurden.rawValue, // %, Discrete (Temporally Weighted)
                HKQuantityTypeIdentifier.heartRate.rawValue, // count/s, Discrete (Temporally Weighted)
                HKQuantityTypeIdentifier.heartRateVariabilitySDNN.rawValue, // ms, Discrete (Arithmetic)
                HKQuantityTypeIdentifier.restingHeartRate.rawValue, // count/min, Discrete (Arithmetic)
                HKQuantityTypeIdentifier.vo2Max.rawValue, // ml/(kg*min), Discrete (Arithmetic)
                // HKQuantityTypeIdentifier.walkingHeartRateAverage.rawValue, // count/min, Discrete (Arithmetic)
                // Vitals
                HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue, // mmHg, Discrete (Arithmetic)
                HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue, // mmHg, Discrete (Arithmetic)
                // HKQuantityTypeIdentifier.insulinDelivery.rawValue, // IU, Cumulative
                // Reproductive Health
                // HKQuantityTypeIdentifier.basalBodyTemperature.rawValue, // degC, Discrete (Arithmetic)
                // Respiratory
                HKQuantityTypeIdentifier.respiratoryRate.rawValue, // count/s, Discrete (Arithmetic)
                // HKQuantityTypeIdentifier.oxygenSaturation.rawValue, // %, Discrete (Arithmetic)
                // Metabolic
                HKQuantityTypeIdentifier.bloodGlucose.rawValue // mg/dL, Discrete (Arithmetic)
            ]
        case .categorySamples:
            return [
                // Sleep
                HKCategoryTypeIdentifier.sleepAnalysis.rawValue // HKCategoryValueSleepAnalysis
            ]
        case .workoutData:
            return ["HKWorkoutTypeIdentifier"]

        case .characteristics:
            return [
                HKCharacteristicTypeIdentifier.biologicalSex.rawValue,
                HKCharacteristicTypeIdentifier.bloodType.rawValue,
                HKCharacteristicTypeIdentifier.dateOfBirth.rawValue,
                HKCharacteristicTypeIdentifier.fitzpatrickSkinType.rawValue,
                HKCharacteristicTypeIdentifier.wheelchairUse.rawValue
            ]
        }
    }

    var types: [HKObjectType] {
        return identifierStrings.compactMap { objectTypeFromString(typeIdentifier: $0) }
    }
}

let MAXIMUM_BATCH_SIZE = 1000

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()

    private let healthStore: HKHealthStore = HKHealthStore()
    private var hasCompletedFullSync: Bool
    private var appIsLocked: Bool = false

    private init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("This app requires a device that supports HealthKit")
        }

        self.hasCompletedFullSync = UserDefaults.standard.bool(forKey: HAS_COMPLETED_FULL_SYNC)

        NotificationCenter.default.addObserver(self, selector: #selector(deviceWillLock), name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidUnlock), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func deviceWillLock() {
        appIsLocked = true
    }

    @objc func deviceDidUnlock() {
        appIsLocked = false
        // Resume sync if it hasn't completed
        if !hasCompletedFullSync {
            Task {
                await syncHealthData()
            }
        }
    }

    public func requestClinicalRecordsPermission() async throws {
        if HKHealthStore.isHealthDataAvailable() {
            try await healthStore.requestAuthorization(toShare: Set(), read: Set(HealthData.clinicalRecords.types))
        } else {
            let error = NSError(domain: Bundle.main.bundleIdentifier!, code: 401, userInfo: [NSLocalizedDescriptionKey: HealthKitError.unavailable.rawValue])
            throw error
        }
    }

    public func requestHealthKitPermission() async throws {
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes: Set<HKObjectType> = Set(
                HealthData.quantitySamples.types
                + HealthData.categorySamples.types
                + HealthData.characteristics.types
                + HealthData.workoutData.types
            )

            try await healthStore.requestAuthorization(toShare: Set(), read: readDataTypes)
        } else {
            throw NSError(domain: Bundle.main.bundleIdentifier!, code: 401, userInfo: [NSLocalizedDescriptionKey: HealthKitError.unavailable.rawValue])
        }
    }

    private func sampleQuery(sampleType: HKSampleType, predicate: NSPredicate?, limit: Int, ascending: Bool = false, processSamples: @escaping ([HKSample]?, Error?, HKSampleType?) -> Void) {
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: getSortDescriptors(ascending: ascending)) { (_, samples, error) in
            processSamples(samples, error, sampleType)
        }
        healthStore.execute(query)
    }

    private func sampleQueries(queryDescriptors: [HKQueryDescriptor], sampleTypes: [HKSampleType], predicate: NSPredicate?, limit: Int, ascending: Bool = false, processSamples: @escaping ([HKSample]?, Error?) -> Void) {
        let query = HKSampleQuery(queryDescriptors: queryDescriptors,
                                   limit: HKObjectQueryNoLimit,
                                  sortDescriptors: getSortDescriptors(ascending: ascending)) { (_, samples, error) in
            processSamples(samples, error)
        }
        healthStore.execute(query)
    }

    private func processQuantitySamples(samples: [HKSample]?) async {
        guard let samples = samples as? [HKQuantitySample] else { return }

        var results: [NSDictionary] = []
        for sample in samples {
            do {
                let sampleType = sample.quantityType
                let dic = try await getPreferredUnits(forTypes: [sampleType], store: healthStore)
                if let unitString = dic[sampleType.identifier] as? String {
                    let unit = HKUnit(from: unitString)
                    let serializedQuantity = serializeQuantitySample(sample: sample, unit: unit)
                    results.append(serializedQuantity)
                } else {
                    AppLogger.instance().error("error getting unitString")
                }
            } catch {
            }
        }

        await self.syncQuantitySamplesToServer(samplesData: results)
    }

    private func processDeletedQuantitySamples(deletedObjects: [HKDeletedObject]?) async {
        guard let deletedObjects else { return }

        var identifiers: [String] = []
        for deletedObject in deletedObjects {
            identifiers.append(deletedObject.uuid.uuidString)
        }

        let requestData: [String: Any] = [
            "identifiers": identifiers
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/quantity_samples/remove", requestData: requestData, requestTimeout: 120)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    private func processClinicalSamples(samples: [HKSample]?) async {
        guard let clinicalRecords = samples as? [HKClinicalRecord] else { return }

        var results: [NSDictionary] = []
        for record in clinicalRecords {
            let serializedRecord = serializeClinicalRecord(record: record)
            results.append(serializedRecord)
        }

        await self.syncClinicalRecordsToServer(recordsData: results)
    }

    private func processDeletedClinicalSamples(deletedObjects: [HKDeletedObject]?) async {
        guard let deletedObjects = deletedObjects else { return }

        var identifiers: [String] = []
        for deletedObject in deletedObjects {
            identifiers.append(deletedObject.uuid.uuidString)
        }

        let requestData: [String: Any] = [
            "identifiers": identifiers
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/clinical_records/remove", requestData: requestData, requestTimeout: 120)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    private func processCategorySamples(samples: [HKSample]?) async {
        guard let samples = samples as? [HKCategorySample] else { return }

        var results: [NSDictionary] = []
        for sample in samples {
            let serializedCategory = serializeCategorySample(sample: sample)
            results.append(serializedCategory)
        }
        await self.syncCategorySamplesToServer(samplesData: results)
    }

    private func processDeletedCategorySamples(deletedObjects: [HKDeletedObject]?) async {
        guard let deletedObjects else { return }

        var identifiers: [String] = []
        for deletedObject in deletedObjects {
            identifiers.append(deletedObject.uuid.uuidString)
        }

        let requestData: [String: Any] = [
            "identifiers": identifiers
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/category_samples/remove", requestData: requestData, requestTimeout: 120)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    private func processWorkoutSamples(samples: [HKSample]?) async {
        guard let samples = samples as? [HKWorkout] else { return }

        var results: [NSDictionary] = []
        for sample in samples {
            let serializedWorkout = serializeWorkout(workout: sample)
            results.append(serializedWorkout)
        }
        await self.syncWorkoutDataToServer(workoutData: results)
    }

    private func processDeletedWorkoutSamples(deletedObjects: [HKDeletedObject]?) async {
        guard let deletedObjects else { return }

        var identifiers: [String] = []
        for deletedObject in deletedObjects {
            identifiers.append(deletedObject.uuid.uuidString)
        }

        let requestData: [String: Any] = [
            "identifiers": identifiers
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/workouts/remove", requestData: requestData, requestTimeout: 120)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    public func syncClinicalRecordsData() async {
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: nil)
        let syncTypes = [
            (HealthData.clinicalRecords.identifierStrings, self.processClinicalSamples, self.processDeletedClinicalSamples)
        ]

        do {
            for (identifiers, processSamples, processDeletedSamples) in syncTypes {
                var predicates: [HKSamplePredicate<HKSample>] = []

                for identifierString in identifiers {
                    if let sampleType = sampleTypeFromString(typeIdentifier: identifierString) {
                        predicates.append(HKSamplePredicate.sample(type: sampleType, predicate: predicate))
                    }
                }

                let anchoredObjectQueryDescriptor = HKAnchoredObjectQueryDescriptor(
                    predicates: predicates,
                    anchor: nil
                )

                do {
                    if await UIApplication.shared.isProtectedDataAvailable {
                        let results = try await anchoredObjectQueryDescriptor.result(for: healthStore)
                        let deletedObjects = results.deletedObjects
                        if !deletedObjects.isEmpty {
                            await processDeletedSamples(deletedObjects)
                        }
                        await processSamples(results.addedSamples)
                    } else {
                        AppLogger.instance("HealthKitService").info("protected data not available, should resume when it is...")
                    }
                } catch {
                    if appIsLocked {
                        throw NSError(domain: Bundle.main.bundleIdentifier!, code: 401, userInfo: [NSLocalizedDescriptionKey: HealthKitError.protectedDataUnavailable.rawValue])
                    }
                    break
                }
            }
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    public func syncHealthData(fullRefresh: Bool = false, numberOfMonthsBack: Int? = 3, inBackground: Bool? = false) async {
        var startPeriod: Date?
        if let numberOfMonthsBack {
            startPeriod = monthsAgo(numOfMonths: numberOfMonthsBack)
        }
        var predicate = HKQuery.predicateForSamples(
            withStart: startPeriod,
            end: nil,
            options: [.strictStartDate]
        )

        if fullRefresh {
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: HAS_COMPLETED_FULL_SYNC)
                self.hasCompletedFullSync = false
                Task {
                    try await AppState.shared.startedSyncingHealthData(inBackground: inBackground)
                }
            }
        }

        // Health Profile Sync
        let healthProfile: [String: Any?] = [
            "biologicalSex": getBiologicalSex(),
            "bloodType": getBloodType(),
            "dateOfBirth": getDateOfBirth(),
            "skinType": getSkinType(),
            "wheelchairUse": getWheelchairUse()
        ]
        await syncHealthProfileToServer(profileData: healthProfile)

        await syncHealthSummaryData(start: startPeriod)

        // For each type of sample (Quantity, Workout, Category), perform the batching.
        let syncTypes = [
            (HealthData.workoutData.identifierStrings, self.processWorkoutSamples, self.processDeletedWorkoutSamples, "workouts"),
            (HealthData.categorySamples.identifierStrings, self.processCategorySamples, self.processDeletedCategorySamples, "category"),
            (HealthData.quantitySamples.identifierStrings, self.processQuantitySamples, self.processDeletedQuantitySamples, "quantity")
        ]

        do {
            for (identifiers, processSamples, processDeletedSamples, queryType) in syncTypes {
                var anchor: HKQueryAnchor? = fullRefresh ? nil : AppState.shared.getQueryAnchor(forKey: "healthDataSync:lastUsedAnchor:\(queryType)")
                var predicates: [HKSamplePredicate<HKSample>] = []

                for identifierString in identifiers {
                    if let sampleType = sampleTypeFromString(typeIdentifier: identifierString) {
                        if queryType == "clinical" || queryType == "workouts" {
                            let clinicalPredicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
                            predicate = clinicalPredicate
                        } else {
                            predicate = HKQuery.predicateForSamples(withStart: startPeriod, end: nil, options: [.strictStartDate])
                        }
                        predicates.append(HKSamplePredicate.sample(type: sampleType, predicate: predicate))
                    }
                }

                while true {
                    let batchSize = MAXIMUM_BATCH_SIZE
                    let anchoredObjectQueryDescriptor = HKAnchoredObjectQueryDescriptor(
                        predicates: predicates,
                        anchor: anchor,
                        limit: batchSize
                    )

                    do {
                        if await UIApplication.shared.isProtectedDataAvailable {
                            let results = try await anchoredObjectQueryDescriptor.result(for: healthStore)

                            let addedSamples = results.addedSamples
                            let deletedObjects = results.deletedObjects
                            anchor = results.newAnchor
                            AppState.shared.setQueryAnchor(anchor: anchor, forKey: "healthDataSync:lastUsedAnchor:\(queryType)")

                            if !deletedObjects.isEmpty {
                                await processDeletedSamples(deletedObjects)
                            }

                            if addedSamples.isEmpty {
                                break
                            }

                            await processSamples(addedSamples)
                        } else {
                            if let startPeriod {
                                FailedSyncStorage.shared.storeFailedDate(startPeriod)
                            }

                            AppLogger.instance("HealthKitService").info("protected data not available, should resume when it is...")
                        }
                    } catch {
                        if appIsLocked {
                            throw NSError(domain: Bundle.main.bundleIdentifier!, code: 401, userInfo: [NSLocalizedDescriptionKey: HealthKitError.protectedDataUnavailable.rawValue])
                        }
                        break
                    }
                }
            }

            DispatchQueue.main.async {
                self.hasCompletedFullSync = true
                UserDefaults.standard.set(true, forKey: HAS_COMPLETED_FULL_SYNC)
                if UserDefaults.standard.bool(forKey: HAS_COMPLETED_HEALTH_DATA_SYNC) == false {
                    Task {
                        await AppState.shared.completedSyncingHealthData()
                    }
                }
                AppLogger.instance("HealthKitService").info("All syncing queries completed.")
            }
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    func syncHealthSummaryData(start: Date?) async {
        var start = start

        let stepType = HKQuantityType(.stepCount)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else {
            fatalError("*** Unable to calculate the end time ***")
        }

        start = FailedSyncStorage.shared.getMinStartDate(start)

        let timeRangePredicate = HKQuery.predicateForSamples(withStart: start, end: endDate)

        let stepsInTimeRange = HKSamplePredicate.quantitySample(type: stepType, predicate: timeRangePredicate)
        let everyDay = DateComponents(day: 1)

        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: stepsInTimeRange,
            options: [.cumulativeSum, .separateBySource],
            anchorDate: endDate,
            intervalComponents: everyDay
        )

        do {
            let stepCounts = try await stepsQuery.result(for: healthStore)
            var results: [NSDictionary] = []

            stepCounts.enumerateStatistics(from: start ?? .distantPast, to: endDate) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    let value = quantity.doubleValue(for: .count())
                    let unit: HKUnit = .count()
                    let serializedQuantity = serializeQuantitySummaryData(date: statistics.startDate, quantity: value, quantityType: stepType, unit: unit, summaryType: "sum")
                    results.append(serializedQuantity)
                }
            }

            try await self.syncQuantitySummariesToServer(data: results)

            if let start {
                FailedSyncStorage.shared.onSuccess(start)
            }
        } catch {
            if let start {
                FailedSyncStorage.shared.storeFailedDate(start)
            }

            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    func setupHealthRecordsBackgroundDelivery() async {
        let syncTypes = [
            (HealthData.clinicalRecords.identifierStrings, self.processClinicalSamples, self.processDeletedClinicalSamples)
        ]

        for (identifiers, processSamples, processDeletedSamples) in syncTypes {
            for identifierString in identifiers {
                guard let sampleType = sampleTypeFromString(typeIdentifier: identifierString) else {
                    continue
                }

                let observerQuery = HKObserverQuery(sampleType: sampleType, predicate: nil) { (_, completionHandler, error) in
                    guard error == nil else {
                        if let error = error {
                            AppLogger.instance().error("error: \(error.localizedDescription)")
                        }
                        return
                    }

                    Task {
                        var anchor: HKQueryAnchor? = AppState.shared.getQueryAnchor(forKey: "healthRecordsBackgroundSync:lastUsedAnchor:\(identifierString)")
                        while true {
                            // Always try and pull all clinical records, since these can be added long after they were performed
                            let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
                            let samplePredicate = HKSamplePredicate.sample(type: sampleType, predicate: predicate)
                            let anchoredObjectQueryDescriptor = HKAnchoredObjectQueryDescriptor(
                                predicates: [samplePredicate],
                                anchor: anchor
                            )
                            do {
                                let results = try await anchoredObjectQueryDescriptor.result(for: self.healthStore)

                                let addedSamples = results.addedSamples
                                let deletedObjects = results.deletedObjects
                                anchor = results.newAnchor
                                AppState.shared.setQueryAnchor(anchor: anchor, forKey: "healthRecordsBackgroundSync:lastUsedAnchor:\(identifierString)")

                                if !deletedObjects.isEmpty {
                                    await processDeletedSamples(deletedObjects)
                                }

                                if addedSamples.isEmpty {
                                    completionHandler()
                                    break
                                }

                                await processSamples(addedSamples)
                            } catch {
                                completionHandler()
                                break
                            }
                        }
                    }
                }

                healthStore.execute(observerQuery)

                do {
                    try await healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate)
                    AppLogger.instance("HealthKitService").info("[\(Date().timeIntervalSince1970)] Successfully enabled background delivery for: \(identifierString)")
                } catch {
                    AppLogger.instance("HealthKitService").error("[\(Date().timeIntervalSince1970)] Failed to enable background delivery for: \(identifierString) -> \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    // Function to set up background delivery
    func setupHealthKitBackgroundDelivery() async {
        let syncTypes = [
            (HealthData.workoutData.identifierStrings, self.processWorkoutSamples, self.processDeletedWorkoutSamples, "workouts"),
            (HealthData.quantitySamples.identifierStrings, self.processQuantitySamples, self.processDeletedQuantitySamples, "quantity"),
            (HealthData.categorySamples.identifierStrings, self.processCategorySamples, self.processDeletedCategorySamples, "category")
        ]

        for (identifiers, processSamples, processDeletedSamples, _) in syncTypes {
            for identifierString in identifiers {
                guard let sampleType = sampleTypeFromString(typeIdentifier: identifierString) else {
                    continue
                }

                let observerQuery = HKObserverQuery(sampleType: sampleType, predicate: nil) { (_, completionHandler, error) in
                    guard error == nil else {
                        if let error = error {
                            AppLogger.instance().error("error: \(error.localizedDescription)")
                        }
                        return
                    }

                    Task {
                        var anchor: HKQueryAnchor? = AppState.shared.getQueryAnchor(forKey: "healthDataBackgroundSync:lastUsedAnchor:\(identifierString)")
                        while true {
                            // This is set in a case where there is no anchor. Should typically be run initially after the first permission grant
                            // so, does not have to be far back into the past.
                            let dayAgo = daysAgo(numOfDays: 1)
                            let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: dayAgo, end: Date())
                            let samplePredicate = HKSamplePredicate.sample(type: sampleType, predicate: predicate)

                            let batchSize = MAXIMUM_BATCH_SIZE
                            let anchoredObjectQueryDescriptor = HKAnchoredObjectQueryDescriptor(
                                predicates: [samplePredicate],
                                anchor: anchor,
                                limit: batchSize
                            )
                            do {
                                let results = try await anchoredObjectQueryDescriptor.result(for: self.healthStore)

                                // For steps, whenever there is an update, fire a summary data sync
                                if identifierString == HKQuantityTypeIdentifier.stepCount.rawValue {
                                    // Set the start period to be 1 week, which should be plenty of time to make sure
                                    // to get all potential updated data
                                    let summaryDataStartPeriod = daysAgo(numOfDays: 7)
                                    await self.syncHealthSummaryData(start: summaryDataStartPeriod)
                                }

                                let addedSamples = results.addedSamples
                                let deletedObjects = results.deletedObjects
                                anchor = results.newAnchor
                                AppState.shared.setQueryAnchor(anchor: anchor, forKey: "healthDataBackgroundSync:lastUsedAnchor:\(identifierString)")

                                if !deletedObjects.isEmpty {
                                    await processDeletedSamples(deletedObjects)
                                }

                                if addedSamples.isEmpty {
                                    completionHandler()
                                    break
                                }

                                await processSamples(addedSamples)
                            } catch {
                                completionHandler()
                                break
                            }
                        }
                    }
                }

                healthStore.execute(observerQuery)

                do {
                    try await healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate)

                    AppLogger.instance("HealthKitService").info("[\(Date().timeIntervalSince1970)] Successfully enabled background delivery for: \(identifierString)")
                } catch {
                    // TODO: Save to lastFailedHealthKitSyncDate?
                    AppLogger.instance("HealthKitService").error("[\(Date().timeIntervalSince1970)] Failed to enable background delivery for: \(identifierString) -> \(error.localizedDescription, privacy: .public)")
                    AppLogger.instance().error("error: \(error.localizedDescription)")
                }
            }
        }
    }

    public func syncWorkoutDataToServer(workoutData: [NSDictionary]) async {
        let requestData: [String: Any] = [
            "workouts": workoutData
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/workouts/sync", requestData: requestData)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    public func syncClinicalRecordsToServer(recordsData: [NSDictionary]) async {
        let requestData: [String: Any] = [
            "records": recordsData
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/clinical_records/sync", requestData: requestData)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    public func syncQuantitySamplesToServer(samplesData: [NSDictionary]) async {
        let requestData: [String: Any] = [
            "samples": samplesData
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/quantity_samples/sync", requestData: requestData, requestTimeout: 120)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    public func syncQuantitySummariesToServer(data: [NSDictionary]) async throws {
        let requestData: [String: Any] = [
            "summaries": data
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/quantity_summaries/sync", requestData: requestData, requestTimeout: 120)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            throw error
        }
    }

    public func syncCategorySamplesToServer(samplesData: [NSDictionary]) async {
        let requestData: [String: Any] = [
            "samples": samplesData
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/category_samples/sync", requestData: requestData, requestTimeout: 120)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    public func syncHealthProfileToServer(profileData: [String: Any?]) async {
        let requestData: [String: Any] = [
            "profile": profileData
        ]

        do {
            _ = try await apiCall(urlPath: "/apple_health/profile/sync", requestData: requestData)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
        }
    }

    private func getBiologicalSex() -> String? {
        do {
            let bioSex = try healthStore.biologicalSex()
            switch bioSex.biologicalSex {
            case .notSet:
                return nil
            case .female:
                return "Female"
            case .male:
                return "Male"
            case .other:
                return "Other"
            default:
                return nil
            }
        } catch {
            return nil
        }
    }

    func getBloodType() -> String? {
        do {
            let blood = try healthStore.bloodType()
            switch blood.bloodType {
            case .notSet:
                return nil
            case .aPositive:
                return "A+"
            case .aNegative:
                return "A-"
            case .bPositive:
                return "B+"
            case .bNegative:
                return "B-"
            case .abPositive:
                return "AB+"
            case .abNegative:
                return "AB-"
            case .oPositive:
                return "O+"
            case .oNegative:
                return "O-"
            default:
                return nil
            }
        } catch {
            return nil
        }
    }

    func getDateOfBirth() -> String? {
        do {
            let dob = try healthStore.dateOfBirthComponents()

            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let dateString = dateFormatter.string(from: dob.date!)
            return dateString
        } catch {
            return nil
        }
    }

    func getSkinType() -> String? {
        do {
            let skin = try healthStore.fitzpatrickSkinType()
            switch skin.skinType {
            case .notSet:
                return nil
            case .I:
                return "I"
            case .II:
                return "II"
            case .III:
                return "III"
            case .IV:
                return "IV"
            case .V:
                return "V"
            case .VI:
                return "VI"
            default:
                return nil
            }
        } catch {
            return nil
        }
    }

    func getWheelchairUse() -> String? {
        do {
            let wheelchairUse = try healthStore.wheelchairUse()
            switch wheelchairUse.wheelchairUse {
            case .notSet:
                return nil
            case .no:
                return "No"
            case .yes:
                return "Yes"
            default:
                return nil
            }
        } catch {
            return nil
        }
    }

    func getStepsData(from startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                      to endDate: Date = Date(),
                      intervalComponents: DateComponents = DateComponents(day: 1)) async -> [(date: Date, stepCount: Double)]? {
        let stepType = HKQuantityType(.stepCount)

        let timeRangePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let stepsInTimeRange = HKSamplePredicate.quantitySample(type: stepType, predicate: timeRangePredicate)

        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: stepsInTimeRange,
            options: [.cumulativeSum, .separateBySource],
            anchorDate: endDate,
            intervalComponents: intervalComponents)

        do {
            let stepCounts = try await stepsQuery.result(for: healthStore)
            var stepsData: [(Date, Double)] = []

            stepCounts.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    let steps = quantity.doubleValue(for: .count())
                    stepsData.append((statistics.startDate, steps))
                }
            }

            return stepsData
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getAverageSteps(from startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!, to endDate: Date = Date()) async -> Double? {
        let stepType = HKQuantityType(.stepCount)

        let timeRangePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let stepsInTimeRange = HKSamplePredicate.quantitySample(type: stepType, predicate: timeRangePredicate)
        let everyDay = DateComponents(day: 1)

        let sumOfStepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: stepsInTimeRange,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: everyDay
        )

        do {
            let stepCounts = try await sumOfStepsQuery.result(for: healthStore)
            var totalSteps: Double = 0
            var totalDays: Double = 0

            stepCounts.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    totalSteps += quantity.doubleValue(for: .count())
                    totalDays += 1
                }
            }

            // Avoid division by zero
            guard totalDays > 0 else {
                return nil
            }

            let averageStepsPerDay = totalSteps / totalDays
            return averageStepsPerDay
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getAverageRestingHeartRate(from startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!, to endDate: Date = Date()) async -> Double? {
        let restingHeartRateType = HKQuantityType(.restingHeartRate)

        let timeRangePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let heartRateInTimeRange = HKSamplePredicate.quantitySample(type: restingHeartRateType, predicate: timeRangePredicate)
        let everyDay = DateComponents(day: 1)

        let restingHeartRateQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: heartRateInTimeRange,
            options: .discreteAverage,
            anchorDate: endDate,
            intervalComponents: everyDay
        )

        do {
            let restingHeartRates = try await restingHeartRateQuery.result(for: healthStore)

            var total: Double = 0
            var totalDays: Double = 0

            restingHeartRates.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let average = statistics.averageQuantity() {
                    total += average.doubleValue(for: HKUnit(from: "count/min"))
                    totalDays += 1
                }
            }

            // Avoid division by zero
            guard totalDays > 0 else {
                return nil
            }

            let averageRestingHeartRate = total / totalDays
            return averageRestingHeartRate
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getAverageNumberOfWorkoutsPerWeek(from startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!, to endDate: Date = Date()) async -> Double? {
        let timeRangePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let workoutsInTimeRange = HKSamplePredicate.workout(timeRangePredicate)

        let workoutsQuery = HKSampleQueryDescriptor(predicates: [workoutsInTimeRange], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)])

        do {
            let workouts = try await workoutsQuery.result(for: healthStore)

            guard workouts.count > 0 else {
                return nil
            }

            let totalWeeks = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 1

            let averageWorkoutsPerWeek = Double(workouts.count) / Double(totalWeeks)

            return averageWorkoutsPerWeek
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getLatestVO2Max() async -> Double? {
        let vo2MaxType = HKQuantityType(.vo2Max)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: vo2MaxType)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )

        do {
            let results = try await descriptor.result(for: healthStore)

            guard results.count > 0 else {
                return nil
            }

            let kgmin = HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute())
            let mL = HKUnit.literUnit(with: .milli)
            let VO2Unit = mL.unitDivided(by: kgmin)

            return results[0].quantity.doubleValue(for: VO2Unit)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getPreviousVO2Max() async -> Double? {
        let vo2MaxType = HKQuantityType(.vo2Max)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: vo2MaxType)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 2
        )

        do {
            let results = try await descriptor.result(for: healthStore)

            guard results.count > 1 else {
                return nil
            }

            let kgmin = HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute())
            let mL = HKUnit.literUnit(with: .milli)
            let VO2Unit = mL.unitDivided(by: kgmin)

            return results[1].quantity.doubleValue(for: VO2Unit)
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getAverageHoursSlept(from startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!, to endDate: Date = Date()) async -> Double? {
        let sleepType = HKCategoryType(.sleepAnalysis)

        let timeRangePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sleepInTimeRange = HKSamplePredicate.categorySample(type: sleepType, predicate: timeRangePredicate)

        let sleepQuery = HKSampleQueryDescriptor(predicates: [sleepInTimeRange], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)])

        do {
            let sleepData = try await sleepQuery.result(for: healthStore)

            let notSleepValues: [Int] = [
                HKCategoryValueSleepAnalysis.inBed.rawValue,
                HKCategoryValueSleepAnalysis.awake.rawValue
            ]

            let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short

            var total: Double = 0
            var totalNights: Set<String> = []

            for sample in sleepData {
                if !notSleepValues.contains(sample.value) {
                    let hoursSlept = sample.endDate.timeIntervalSince(sample.startDate) / 3600
                    total += hoursSlept

                    // Use the end date to determine the night
                    let endDateString = dateFormatter.string(from: sample.endDate)
                    totalNights.insert(endDateString)
                }
            }

            // Avoid division by zero
            guard totalNights.count > 0 else {
                return nil
            }

            let averageHoursSlept = total / Double(totalNights.count)

            return averageHoursSlept
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getLatestHeight() async -> Double? {
        let heightType = HKQuantityType(.height)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: heightType)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )

        do {
            let results = try await descriptor.result(for: healthStore)

            guard results.count > 0 else {
                return nil
            }

            return results[0].quantity.doubleValue(for: .inch()) // assumes inches perferred
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getLatestWeight() async -> Double? {
        let bodyMassType = HKQuantityType(.bodyMass)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: bodyMassType)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )

        do {
            let results = try await descriptor.result(for: healthStore)

            guard results.count > 0 else {
                return nil
            }

            return results[0].quantity.doubleValue(for: .pound()) // assumes lbs perferred
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getLatestBMI() async -> Double? {
        let type = HKQuantityType(.bodyMassIndex)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: type)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )

        do {
            let results = try await descriptor.result(for: healthStore)

            guard results.count > 0 else {
                return nil
            }

            return results[0].quantity.doubleValue(for: .count())
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getLatestBodyFat() async -> Double? {
        let type = HKQuantityType(.bodyFatPercentage)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: type)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )

        do {
            let results = try await descriptor.result(for: healthStore)

            guard results.count > 0 else {
                return nil
            }

            return results[0].quantity.doubleValue(for: .percent())
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getAverageRespiratoryRate(from startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!, to endDate: Date = Date()) async -> Double? {
        let respiratoryRateType = HKQuantityType(.respiratoryRate)

        let timeRangePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let respiratoryRateInTimeRange = HKSamplePredicate.quantitySample(type: respiratoryRateType, predicate: timeRangePredicate)
        let everyDay = DateComponents(day: 1)

        let respiratoryRateQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: respiratoryRateInTimeRange,
            options: .discreteAverage,
            anchorDate: endDate,
            intervalComponents: everyDay
        )

        do {
            let respiratoryRates = try await respiratoryRateQuery.result(for: healthStore)

            var total: Double = 0
            var totalDays: Double = 0

            respiratoryRates.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let average = statistics.averageQuantity() {
                    total += average.doubleValue(for: HKUnit(from: "count/min"))
                    totalDays += 1
                }
            }

            // Avoid division by zero
            guard totalDays > 0 else {
                return nil
            }

            let averageRespiratoryRate = total / totalDays
            return averageRespiratoryRate
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }

    func getLabResults() async -> [String: [LabResultData]]? {
        let labResultRecord = HKClinicalType(.labResultRecord)

        let now = Date()
        let allResults = HKQuery.predicateForSamples(withStart: nil, end: now)
        let labResultsThisYear = HKSamplePredicate.clinicalRecord(type: labResultRecord, predicate: allResults)

        let labResultsQuery = HKSampleQueryDescriptor(predicates: [labResultsThisYear], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)])

        do {
            let resultsData = try await labResultsQuery.result(for: healthStore)

            var groupedLabResults: [String: [LabResultData]] = [:]

            for sample in resultsData {
                guard let fhirResource = sample.fhirResource else { continue }
                guard let result = decodeLabResult(resource: fhirResource) else { continue }
                guard let label = result.label?.lowercased() else { continue }

                if result.value != nil {
                    if groupedLabResults[label] == nil {
                        groupedLabResults[label] = []
                    }
                    groupedLabResults[label]?.append(result)
                    groupedLabResults[label]?.sort { $0.date ?? Date() < $1.date ?? Date() }

                } else {
                    if groupedLabResults["Other"] == nil {
                        groupedLabResults["Other"] = []
                    }
                    groupedLabResults["Other"]?.append(result)
                    groupedLabResults["Other"]?.sort { $0.date ?? Date() < $1.date ?? Date() }
                }
            }

            return groupedLabResults
        } catch {
            AppLogger.instance().error("error: \(error.localizedDescription)")
            return nil
        }
    }
}

extension HKFitzpatrickSkinType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notSet: return "Not Set"
        case .I: return "Type I"
        case .II: return "Type II"
        case .III: return "Type III"
        case .IV: return "Type IV"
        case .V: return "Type V"
        case .VI: return "Type VI"
        default: return "Unknown"
        }
    }
}

extension HKBiologicalSex: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notSet: return "Not Set"
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Other"
        default: return "Unknown"
        }
    }
}

extension HKBloodType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notSet: return "Not Set"
        case .aPositive: return "A+"
        case .aNegative: return "A-"
        case .bPositive: return "B+"
        case .bNegative: return "B-"
        case .abPositive: return "AB+"
        case .abNegative: return "AB-"
        case .oPositive: return "O+"
        case .oNegative: return "O-"
        default: return "Unknown"
        }
    }
}

extension HKWheelchairUse: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notSet: return "Not Set"
        case .no: return "No"
        case .yes: return "Yes"
        default: return "Unknown"
        }
    }
}

let bloodTypeOptions: [HKBloodType] = [
    .aPositive,
    .aNegative,
    .bPositive,
    .bNegative,
    .abPositive,
    .abNegative,
    .oPositive,
    .oNegative
]
let sexOptions: [HKBiologicalSex] = [
    .female,
    .male,
    .other
]
let wheelchairOptions: [HKWheelchairUse] = [
    .no,
    .yes
]

import SwiftUI
import AlertToast

struct AppleHealthConnectionDetailsView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var isAuthorizingHealthKit: Bool = false
    @State private var hasAuthorizedHealthRecords: Bool = AppState.shared.hasAuthorizedHealthRecords
    @State private var hasAuthorizedHealthKit: Bool = AppState.shared.hasAuthorizedHealthKit
    @State private var isSyncingHealthData: Bool = false
    @State private var isShowingDataSyncConfirmation: Bool = false
    @State private var showAuthorizationSuccess: Bool = false

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            List {
                Section {
                    Button(action: {
                        if let url = URL(string: "App-prefs:HEALTH") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }) {
                        HStack {
                            Image("Apple Health Icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .frame(width: 24, alignment: .center)
                                .shadow(color: .gray, radius: 0.5, x: 0, y: 0)
                            Text("Apple Health Settings")
                            Spacer()
                            NavigationLinkIconView()
                        }

                    }
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                }

                Section(
                    header: SectionHeaderView(title: "Health Data"),
                    footer: SectionFooterView(text: "Depending on how much data you have, full data syncs may take a while to finish. If there's new health data types available in Sentinel, it'll prompt you to authorize the new data types.")
                ) {
                    Button(action: {
                        Task {
                            do {
                                try await handleHealthDataSync()
                                showAuthorizationSuccess = true
                            } catch {
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    }) {
                        if isSyncingHealthData {
                            HStack {
                                Text("Syncing Data")
                                Spacer()
                                ProgressView()
                            }
                        } else {
                            if AppState.shared.hasAuthorizedHealthKit {
                                Text("Re-sync Apple Health Data")
                            } else {
                                Text("Authorize & Sync Apple Health Data")
                            }
                        }
                    }
                    .opacity(isSyncingHealthData ? 0.5 : 1.0)
                    .disabled(isSyncingHealthData)
                }

                Section(
                    header: SectionHeaderView(title: "Health Records"),
                    footer: SectionFooterView(text: "Syncing your records will also trigger an authorization prompt if you aren't automatically sharing new records with Sentinel.")
                ) {
                    Button(action: {
                        Task {
                            do {
                                try await handleHealthRecordsSync()
                                showAuthorizationSuccess = true
                            } catch {
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    }) {
                        if AppState.shared.hasAuthorizedHealthRecords {
                            Text("Re-Sync Health Records")
                        } else {
                            Text("Authorize & Sync Health Records")
                        }
                    }
                }
            }
            .onReceive(AppState.shared.$isSyncingAllHealthData) { isSyncing in
                isSyncingHealthData = isSyncing
            }
            .onReceive(AppState.shared.$hasAuthorizedHealthKit) { hasAuthorized in
                hasAuthorizedHealthKit = hasAuthorized
            }
            .toast(isPresenting: $showAuthorizationSuccess) {
                AlertToast(
                    displayMode: .alert,
                    type: .complete(.green),
                    title: "Success!"
                )
            }
            if isAuthorizingHealthKit {
                LoadingOverlayView()
            }
        }
    }

    func handleHealthDataSync() async throws {
        self.isAuthorizingHealthKit = true
        try await HealthKitService.shared.requestHealthKitPermission()
        await AppState.shared.authorizedHealthKit()
        self.isAuthorizingHealthKit = false
        await HealthKitService.shared.syncHealthData(fullRefresh: true, numberOfMonthsBack: 12)
    }

    func handleHealthRecordsSync() async throws {
        self.isAuthorizingHealthKit = true
        try await HealthKitService.shared.requestClinicalRecordsPermission()
        await AppState.shared.authorizedHealthRecords()
        await HealthKitService.shared.syncClinicalRecordsData()
        self.isAuthorizingHealthKit = false
    }
}

// #Preview {
//    AppleHealthConnectionDetailsView()
// }

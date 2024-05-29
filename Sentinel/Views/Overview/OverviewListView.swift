import SwiftUI

struct OverviewListView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var viewModel: HomeViewModel

    @State var isInitialLoad: Bool = true
    @State var showingSettingsModal = false
    @State var showNotificationAlert: Bool = false
    @State var showingChatModal = false
    @State var isSyncingHealthData: Bool = false
    @State var notificationAlert: NotificationAlert?
    @State var hasDismissedDataAlert: Bool = UserDefaults.standard.bool(forKey: HAS_DISMISSED_DATA_ALERT)

    var hasSomeMissingData: Bool {
        if let fitnessStats = viewModel.fitnessStats {
            var missingStats: [String] = []
            if fitnessStats.restingHeartRate == nil {
                missingStats.append("restingHeartRate")
            }
            if fitnessStats.steps == nil {
                missingStats.append("steps")
            }
            if fitnessStats.workouts == nil {
                missingStats.append("workouts")
            }
            if fitnessStats.vo2Max == nil {
                missingStats.append("vo2Max")
            }
            if fitnessStats.respiratoryRate == nil {
                missingStats.append("respiratoryRate")
            }

            return missingStats.count > 0 && missingStats.count < 4
        }
        if let sleepStats = viewModel.sleepStats {
            return sleepStats.sleep == nil
        }
        if let bodyStats = viewModel.bodyStats {
            if bodyStats.height == nil {
                return true
            }
            if bodyStats.weight == nil {
                return true
            }
            if bodyStats.bodyFat == nil {
                return true
            }
            if bodyStats.bmi == nil {
                return true
            }
        }
        if viewModel.biomarkers.count > 0 && viewModel.biomarkers.count < 6 {
            return true
        }

        return false
    }

    var body: some View {
        GeometryReader { geometry in
            List {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                    }
                    .padding()
                    .listRowSeparator(.hidden)
                    .listRowBackground(EmptyView())
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                } else {
                    if self.isSyncingHealthData {
                        SyncingDataAlertView()
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    } else if hasSomeMissingData && hasDismissedDataAlert != true {
                        AlertView(
                            alert: AlertViewContent(
                                title: "Add more data",
                                message: "Did you know that you could be getting even more personalized recommendations and tips?\n\nTry adding some more health data connections to get even better suggestions from Sentinel.",
                                action: {
                                    dismissDataAlert()
                                }
                            ),
                            onDismiss: {
                                dismissDataAlert()
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }

                    if showNotificationAlert, let notificationAlert = self.notificationAlert {
                        AlertView(alert: AlertViewContent(
                            title: notificationAlert.title,
                            message: notificationAlert.message,
                            action: {
                                if let chatPrompt = notificationAlert.chatPrompt {
                                    chatViewModel.startConversationWithPrompt(chatPrompt: chatPrompt)
                                    tabsViewModel.changeTab("chat")
                                    AppState.shared.notificationAlert = nil
                                }
                            }),
                            onDismiss: {
                                AppState.shared.notificationAlert = nil
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }

                    BiomarkersSectionView()
                        .environmentObject(viewModel)
                        .environmentObject(chatViewModel)
                        .environmentObject(tabsViewModel)

                    BodySectionView()
                        .environmentObject(viewModel)

                    FitnessSectionView()
                        .environmentObject(viewModel)

                    SleepSectionView()
                        .environmentObject(viewModel)

                    if viewModel.conditions.count > 0 {
                        ConditionsSectionView()
                            .environmentObject(viewModel)
                            .environmentObject(chatViewModel)
                            .environmentObject(tabsViewModel)
                    }

                    if viewModel.medications.count > 0 {
                        MedicationsSectionView()
                            .environmentObject(viewModel)
                            .environmentObject(chatViewModel)
                            .environmentObject(tabsViewModel)
                    }

                    if viewModel.allergies.count > 0 {
                        AllergiesSectionView()
                            .environmentObject(viewModel)
                            .environmentObject(chatViewModel)
                            .environmentObject(tabsViewModel)
                    }

                    if viewModel.immunizations.count > 0 {
                        ImmunizationsSectionView()
                            .environmentObject(viewModel)
                            .environmentObject(chatViewModel)
                            .environmentObject(tabsViewModel)
                    }

                    if viewModel.procedures.count > 0 {
                        ProceduresSectionView()
                            .environmentObject(viewModel)
                            .environmentObject(chatViewModel)
                            .environmentObject(tabsViewModel)
                    }
                }

            }
            .refreshable {
                await loadData()
            }
            .task {
                await loadData()
                await Session.shared.syncTimezone()
            }
            .onReceive(AppState.shared.$isSyncingAllHealthData) { isSyncing in
                // only show if sync is not in background
                if AppState.shared.isSyncingHealthDataInBackground {
                    isSyncingHealthData = false
                } else {
                    isSyncingHealthData = isSyncing
                }
            }
            .onReceive(AppState.shared.$notificationAlert) { alert in
                showNotificationAlert = true
                notificationAlert = alert
            }
            .onReceive(AppState.shared.$labTestOrderNotificationOpened) { labTestOrderOpened in
                if labTestOrderOpened {
                    Task {
                        do {
                            try await self.viewModel.fetchLabTestOrders()
                        } catch {
                        }
                    }
                }
            }
            .onReceive(viewModel.$kickOffResync) { resync in
                if resync {
                    Task {
                        await HealthKitService.shared.syncHealthData(
                            fullRefresh: true,
                            numberOfMonthsBack: 12,
                            inBackground: true
                        )
                        DispatchQueue.main.async {
                            viewModel.kickOffResync = false
                        }
                    }
                }
            }
            .listSectionSpacing(.compact)
        }
    }

    func loadData() async {
        if isInitialLoad {
            viewModel.isLoading = true
        }

        // TODO: handle errors for each and overall
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await self.viewModel.fetchBiomarkers()
                } catch {
                    // Handle any errors that occurred in any of the tasks
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchFitnessStats()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchSleepStats()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchBodyStats()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchConditions()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchMedications()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchAllergies()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchImmunizations()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchProcedures()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await Session.shared.syncUser()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchLabTestOrders()
                } catch {
                }
            }
            group.addTask {
                do {
                    try await self.viewModel.fetchLabTests()
                } catch {
                }
            }
        }

        viewModel.isLoading = false

        if isInitialLoad {
            isInitialLoad = false
        }
    }

    func dismissDataAlert() {
        UserDefaults.standard.set(true, forKey: HAS_DISMISSED_DATA_ALERT)
        hasDismissedDataAlert = true
    }
}

#Preview {
    OverviewListView()
}

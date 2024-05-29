import SwiftUI

struct FitnessSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: HomeViewModel

    @State private var isLoading: Bool = false
    @State private var isLoadingSilently: Bool = false
    @State var isInitialLoad: Bool = true
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var isEmpty: Bool {
        if (viewModel.fitnessStats?.steps) != nil {
            return false
        }
        if (viewModel.fitnessStats?.workouts) != nil {
            return false
        }
        if (viewModel.fitnessStats?.restingHeartRate) != nil {
            return false
        }
        if (viewModel.fitnessStats?.vo2Max) != nil {
            return false
        }
        if (viewModel.fitnessStats?.respiratoryRate) != nil {
            return false
        }

        return true
    }

    var body: some View {
        HomeSectionView(
            title: "Fitness",
            iconName: "figure.run",
            iconColor: .mint,
            content: {
                if isLoading {
                    LazyVStack {
                        ProgressView()
                    }
                    .padding()
                } else if showError {
                    LazyVStack(spacing: 12) {
                        Text("There was an error fetching your fitness stats. Please try again or contact support.")
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                do {
                                    showError = false
                                    try await viewModel.fetchFitnessStats()
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if isEmpty && isLoadingSilently != true {
                    EmptyStateView(
                        title: "No Fitness Data",
                        description: "",
                        actions: {EmptyView()}
                    )
                } else {
                    if let steps = viewModel.fitnessStats?.steps?.latestMeasurement, let statText = getStepCountText(steps.value) {
                        HealthStatCardView(
                            title: "Steps",
                            icon: Image(systemName: "figure.walk"),
                            iconColor: .green,
                            statText: statText,
                            statUnitText: nil,
                            statDateString: steps.from,
                            statDescription: steps.description,
                            trendStat: getStepTrendStatText(viewModel.fitnessStats?.steps?.trendMeasurement)
                        )
                    }

                    if let workouts = viewModel.fitnessStats?.workouts?.latestMeasurement, let statText = getWorkoutsText(workouts.value) {
                        HealthStatCardView(
                            title: "Workouts",
                            icon: Image(systemName: "figure.run"),
                            iconColor: .yellow,
                            statText: statText,
                            statUnitText: workouts.unit,
                            statDateString: workouts.from,
                            statDescription: workouts.description,
                            trendStat: getWorkoutsTrendStatText(viewModel.fitnessStats?.workouts?.trendMeasurement)
                        )
                    }

                    if let restingHeartRate = viewModel.fitnessStats?.restingHeartRate?.latestMeasurement, let statText = getRestingHeartRateText(restingHeartRate.value) {
                        HealthStatCardView(
                            title: "Resting Heart Rate",
                            icon: Image(systemName: "heart"),
                            iconColor: .red,
                            statText: statText,
                            statUnitText: restingHeartRate.unit,
                            statDateString: restingHeartRate.from,
                            statDescription: restingHeartRate.description,
                            trendStat: getRestingHeartRateTrendStatText(viewModel.fitnessStats?.restingHeartRate?.trendMeasurement)
                        )
                    }

                    if let vo2Max = viewModel.fitnessStats?.vo2Max?.latestMeasurement, let statText = getVO2MaxText(vo2Max.value) {
                        HealthStatCardView(
                            title: "VO2 Max",
                            icon: Image(systemName: "bolt.heart"),
                            iconColor: .blue,
                            statText: statText,
                            statUnitText: nil,
                            statDateString: vo2Max.from,
                            statDescription: vo2Max.description,
                            trendStat: getVO2MaxTrendStatText(viewModel.fitnessStats?.vo2Max?.trendMeasurement)
                        )
                    }

                    if let respiratoryRate = viewModel.fitnessStats?.respiratoryRate?.latestMeasurement, let statText = getRestingHeartRateText(respiratoryRate.value) {
                        HealthStatCardView(
                            title: "Respiratory Rate",
                            icon: Image(systemName: "lungs"),
                            iconColor: .purple,
                            statText: statText,
                            statUnitText: respiratoryRate.unit,
                            statDateString: respiratoryRate.from,
                            statDescription: respiratoryRate.description,
                            trendStat: getRespiratoryRateTrendStatText(viewModel.fitnessStats?.respiratoryRate?.trendMeasurement)
                        )
                    }
                }
            }
        )
    }

    private func getStepCountText(_ steps: Double?) -> String? {
        if let steps = steps {
            return "\(formatNumber(steps, maximumDecimals: 0))"
        } else {
            return nil
        }
    }

    private func getStepTrendStatText(_ trendStat: HealthDataMeasurement?) -> String? {
        if let trendStat = trendStat {
            if var trendString = getStepCountText(trendStat.value) {
                if let description = trendStat.description {
                    trendString = "\(trendString) \(description)"
                }

                return trendString
            } else {
                return nil
            }
        }
        return nil
    }

    private func getWorkoutsText(_ workouts: Double?) -> String? {
        if let workouts = workouts {
            return "\(formatNumber(workouts, maximumDecimals: 0))"
        } else {
            return nil
        }
    }

    private func getWorkoutsTrendStatText(_ trendStat: HealthDataMeasurement?) -> String? {
        if let trendStat = trendStat {
            if var trendString = getWorkoutsText(trendStat.value) {
                if let unit = trendStat.unit {
                    trendString = "\(trendString) \(unit)"
                }
                if let description = trendStat.description {
                    trendString = "\(trendString) \(description)"
                }

                return trendString
            } else {
                return nil
            }
        }
        return nil
    }

    private func getVO2MaxText(_ vo2Max: Double?) -> String? {
        if let vo2Max = vo2Max {
            return "\(formatNumber(vo2Max, maximumDecimals: 2))"
        } else {
            return nil
        }
    }

    private func getVO2MaxTrendStatText(_ trendStat: HealthDataMeasurement?) -> String? {
        if let trendStat = trendStat {
            if var trendString = getVO2MaxText(trendStat.value) {
                if let description = trendStat.description {
                    trendString = "\(trendString) \(description)"
                }

                return trendString
            } else {
                return nil
            }
        }
        return nil
    }

    private func getRestingHeartRateText(_ restingHeartRate: Double?) -> String? {
        if let restingHeartRate = restingHeartRate {
            return formatNumber(restingHeartRate, maximumDecimals: 0)
        } else {
            return nil
        }
    }

    private func getRestingHeartRateTrendStatText(_ trendStat: HealthDataMeasurement?) -> String? {
        if let trendStat = trendStat {
            if var trendString = getRestingHeartRateText(trendStat.value) {
                if let unit = trendStat.unit {
                    trendString = "\(trendString) \(unit)"
                }
                if let description = trendStat.description {
                    trendString = "\(trendString) \(description)"
                }

                return trendString
            } else {
                return nil
            }
        }
        return nil
    }

    private func getRespiratoryRateText(_ respiratoryRate: Double?) -> String? {
        if let respiratoryRate = respiratoryRate {
            return formatNumber(respiratoryRate, maximumDecimals: 1)
        } else {
            return nil
        }
    }

    private func getRespiratoryRateTrendStatText(_ trendStat: HealthDataMeasurement?) -> String? {
        if let trendStat = trendStat {
            if var trendString = getRespiratoryRateText(trendStat.value) {
                if let unit = trendStat.unit {
                    trendString = "\(trendString) \(unit)"
                }
                if let description = trendStat.description {
                    trendString = "\(trendString) \(description)"
                }

                return trendString
            } else {
                return nil
            }
        }
        return nil
    }
}

// #Preview {
//    ExerciseSectionView()
// }

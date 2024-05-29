import SwiftUI

struct BodySectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: HomeViewModel

    @State private var isLoading: Bool = false
    @State private var isLoadingSilently: Bool = false
    @State var isInitialLoad: Bool = true
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var isEmpty: Bool {
        if (viewModel.bodyStats?.bodyFat) != nil {
            return false
        }
        if (viewModel.bodyStats?.bmi) != nil {
            return false
        }
        if (viewModel.bodyStats?.height) != nil {
            return false
        }
        if (viewModel.bodyStats?.weight) != nil {
            return false
        }

        return true
    }

    var body: some View {
        HomeSectionView(
            title: "Body",
            iconName: "figure",
            iconColor: .purple,
            content: {
                if isLoading {
                    LazyVStack {
                        ProgressView()
                    }
                    .padding()
                } else if showError {
                    LazyVStack(spacing: 12) {
                        Text("There was an error fetching your body stats. Please try again or contact support.")
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                do {
                                    showError = false
                                    try await viewModel.fetchBodyStats()
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
                        title: "No Body Data",
                        description: "",
                        actions: {EmptyView()}
                    )
                } else {
                    if let height = viewModel.bodyStats?.height?.latestMeasurement, let statText = getHeightText(height.value, unit: height.unit) {
                        HealthStatCardView(
                            title: "Height",
                            icon: Image(systemName: "figure"),
                            iconColor: .cyan,
                            statText: statText,
                            statUnitText: nil,
                            statDateString: height.from,
                            statDescription: height.description,
                            trendStat: nil
                        )
                    }

                    if let weight = viewModel.bodyStats?.weight?.latestMeasurement, let statText = getWeightText(weight.value) {
                        HealthStatCardView(
                            title: "Weight",
                            icon: Image(systemName: "figure.stand"),
                            iconColor: .green,
                            statText: statText,
                            statUnitText: weight.unit,
                            statDateString: weight.from,
                            statDescription: weight.description,
                            trendStat: getWeightTrendStatText(viewModel.bodyStats?.weight?.trendMeasurement)
                        )
                    }

                    if let bodyFat = viewModel.bodyStats?.bodyFat?.latestMeasurement, let statText = getBodyFatText(bodyFat.value) {
                        HealthStatCardView(
                            title: "Body Fat",
                            icon: Image(systemName: "figure.stand"),
                            iconColor: .purple,
                            statText: statText,
                            statUnitText: bodyFat.unit,
                            statDateString: bodyFat.from,
                            statDescription: bodyFat.description,
                            trendStat: getBodyFatTrendStatText(viewModel.bodyStats?.bodyFat?.trendMeasurement)
                        )
                    }

                    if let bmi = viewModel.bodyStats?.bmi?.latestMeasurement, let statText = getBMIText(bmi.value) {
                        HealthStatCardView(
                            title: "BMI",
                            icon: Image(systemName: "figure.arms.open"),
                            iconColor: .orange,
                            statText: statText,
                            statUnitText: nil,
                            statDateString: bmi.from,
                            statDescription: bmi.description,
                            trendStat: getBMITrendStatText(viewModel.bodyStats?.bmi?.trendMeasurement)
                        )
                    }
                }
            }
        )
    }

    private func getHeightText(_ height: Double?, unit: String?) -> String? {
        if let height = height {
            return formatHeight(height, heightUnit: unit)
        } else {
            return nil
        }
    }

    private func getWeightText(_ weight: Double?) -> String? {
        if let weight = weight {
            return formatNumber(weight, maximumDecimals: 0)
        } else {
            return nil
        }
    }

    private func getWeightTrendStatText(_ trendStat: HealthDataMeasurement?) -> String? {
        if let trendStat = trendStat {
            if var trendString = getWeightText(trendStat.value) {
                if let unit = trendStat.unit {
                    trendString = "\(trendString)\(unit)"
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

    private func getBodyFatText(_ bodyFat: Double?) -> String? {
        if let bodyFat = bodyFat {
            return formatNumber(bodyFat, maximumDecimals: 1)
        } else {
            return nil
        }
    }

    private func getBodyFatTrendStatText(_ trendStat: HealthDataMeasurement?) -> String? {
        if let trendStat = trendStat {
            if var trendString = getBodyFatText(trendStat.value) {
                if let unit = trendStat.unit {
                    trendString = "\(trendString)\(unit)"
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

    private func getBMIText(_ bmi: Double?) -> String? {
        if let bmi = bmi {
            return formatNumber(bmi, maximumDecimals: 1)
        } else {
            return nil
        }
    }

    private func getBMITrendStatText(_ trendStat: HealthDataMeasurement?) -> String? {
        if let trendStat = trendStat {
            if var trendString = getBMIText(trendStat.value) {
                if let unit = trendStat.unit {
                    trendString = "\(trendString)\(unit)"
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

#Preview {
    BodySectionView()
}

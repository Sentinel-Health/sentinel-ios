import SwiftUI

struct SleepSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: HomeViewModel

    @State private var isLoading: Bool = false
    @State private var isLoadingSilently: Bool = false
    @State var isInitialLoad: Bool = true
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        HomeSectionView(
            title: "Sleep",
            iconName: "bed.double",
            iconColor: .indigo,
            content: {
                if isLoading {
                    LazyVStack {
                        ProgressView()
                    }
                    .padding()
                } else if showError {
                    LazyVStack(spacing: 12) {
                        Text("There was an error fetching your sleep stats. Please try again or contact support.")
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                do {
                                    showError = false
                                    try await viewModel.fetchSleepStats()
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if viewModel.sleepStats?.sleep == nil && isLoadingSilently != true {
                    EmptyStateView(
                        title: "No Sleep Data",
                        description: "",
                        actions: {EmptyView()}
                    )
                } else {
                    if let sleep = viewModel.sleepStats?.sleep?.latestMeasurement, let statText = getSleepStatText(sleep.value) {
                        HealthStatCardView(
                            title: "Sleep",
                            icon: Image(systemName: "powersleep"),
                            iconColor: .cyan,
                            statText: statText,
                            statUnitText: nil,
                            statDateString: sleep.from,
                            statDescription: sleep.description,
                            trendStat: getSleepTrendStatText(viewModel.sleepStats?.sleep?.trendMeasurement)
                        )
                    }
                }
            }
        )
    }

    private func getSleepStatText(_ hours: Double?) -> String? {
        if let hoursSlept = hours {
            let hours = Int(floor(hoursSlept))
            let minutes = (hoursSlept - floor(hoursSlept)) * 60
            return "\(hours)h\(Int(minutes.rounded()))m"
        } else {
            return nil
        }
    }

    private func getSleepTrendStatText(_ trendStat: HealthDataMeasurement?) -> String? {
        if let trendStat = trendStat {
            if var trendString = getSleepStatText(trendStat.value) {
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
//    SleepSectionView()
// }

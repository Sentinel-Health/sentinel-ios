import SwiftUI

struct ConditionsSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    @State private var isLoading: Bool = false
    @State private var isLoadingSilently: Bool = false
    @State var isInitialLoad: Bool = true
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        HomeSectionView(
            title: "Medical Conditions",
            iconName: "stethoscope",
            iconColor: Color.purple,
            content: {
                if isLoading {
                    LazyVStack {
                        ProgressView()
                    }
                    .padding()
                } else if showError {
                    LazyVStack(spacing: 12) {
                        Text("There was an error fetching your medical conditions. Please try again or contact support.")
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                do {
                                    showError = false
                                    try await homeViewModel.fetchConditions()
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    let conditionsToShow = homeViewModel.conditions.prefix(5)
                    ForEach(conditionsToShow) { condition in
                        ConditionCellView(condition: condition)
                            .environmentObject(chatViewModel)
                            .environmentObject(homeViewModel)
                            .environmentObject(tabsViewModel)
                    }
                    if homeViewModel.conditions.count > 5 {
                        NavigationLink {
                            AllConditionsListView()
                                .environmentObject(homeViewModel)
                                .environmentObject(chatViewModel)
                                .environmentObject(tabsViewModel)
                        } label: {
                            Text("See more")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        )
    }
}

// #Preview {
//    ConditionsSectionView()
// }

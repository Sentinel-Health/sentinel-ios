import SwiftUI

struct ImmunizationsSectionView: View {
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
            title: "Vaccines",
            iconName: "cross.vial",
            iconColor: Color.green,
            content: {
                if isLoading {
                    LazyVStack {
                        ProgressView()
                    }
                    .padding()
                } else if showError {
                    LazyVStack(spacing: 12) {
                        Text("There was an error fetching your vaccines. Please try again or contact support.")
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                do {
                                    showError = false
                                    try await homeViewModel.fetchImmunizations()
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    let immunizationsToShow = homeViewModel.immunizations.prefix(5)
                    ForEach(immunizationsToShow) { immunization in
                        ImmunizationCellView(immunization: immunization)
                            .environmentObject(homeViewModel)
                            .environmentObject(chatViewModel)
                            .environmentObject(tabsViewModel)
                    }
                    if homeViewModel.immunizations.count > 5 {
                        NavigationLink {
                            AllImmunizationsListView()
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

#Preview {
    ImmunizationsSectionView()
}

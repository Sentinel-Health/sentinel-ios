import SwiftUI

struct AllergiesSectionView: View {
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
            title: "Allergies",
            iconName: "allergens",
            iconColor: Color.orange,
            content: {
                if isLoading {
                    LazyVStack {
                        ProgressView()
                    }
                    .padding()
                } else if showError {
                    LazyVStack(spacing: 12) {
                        Text("There was an error fetching your allergies. Please try again or contact support.")
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                do {
                                    showError = false
                                    try await homeViewModel.fetchAllergies()
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    let allergiesToShow = homeViewModel.allergies.prefix(5)
                    ForEach(allergiesToShow) { allergy in
                        AllergyCellView(allergy: allergy)
                            .environmentObject(chatViewModel)
                            .environmentObject(homeViewModel)
                            .environmentObject(tabsViewModel)
                    }
                    if homeViewModel.allergies.count > 5 {
                        NavigationLink {
                            AllAllergiesListView()
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
//    AllergiesSectionView()
// }

import SwiftUI

struct MedicationsSectionView: View {
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
            title: "Medications",
            iconName: "pills.fill",
            iconColor: Color.teal,
            content: {
                if isLoading {
                    LazyVStack {
                        ProgressView()
                    }
                    .padding()
                } else if showError {
                    LazyVStack(spacing: 12) {
                        Text("There was an error fetching your medications. Please try again or contact support.")
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                do {
                                    showError = false
                                    try await homeViewModel.fetchMedications()
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    let medicationsToShow = homeViewModel.medications.prefix(5)
                    ForEach(medicationsToShow) { medication in
                        MedicationCellView(medication: medication)
                            .environmentObject(chatViewModel)
                            .environmentObject(homeViewModel)
                            .environmentObject(tabsViewModel)
                    }
                    if homeViewModel.medications.count > 5 {
                        NavigationLink {
                            AllMedicationsListView()
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
//    MedicationsSectionView()
// }

import SwiftUI

struct BiomarkersSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel

    @State private var isLoading: Bool = false
    @State private var isLoadingSilently: Bool = false
    @State var isInitialLoad: Bool = true
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showOrderLabs: Bool = false

    var defaultCategoryOrder: [String: (iconName: String, color: Color)] = [
        "Cardiovascular Health": ("heart.fill", .red),
        "Metabolic Health": ("flame.fill", .orange),
        "Liver Health": ("staroflife.fill", .green),
        "Kidney Health": ("waveform.path.ecg", .blue),
        "Blood Health": ("drop.halffull", .purple),
        "Vitamins, Minerals & Electrolytes": ("pills.fill", .yellow),
        "Fatty Acids": ("drop.degreesign", .cyan),
        "Uncategorized": ("questionmark", .gray)
    ]

    var orderedCategoryNames: [String] {
        ["Cardiovascular Health",
         "Metabolic Health",
         "Liver Health",
         "Kidney Health",
         "Blood Health",
         "Vitamins, Minerals & Electrolytes",
         "Fatty Acids",
         "Uncategorized"]
    }

    let visibleWhenEmptyCategories: [String] = [
        "Cardiovascular Health",
        "Metabolic Health",
        "Liver Health",
        "Kidney Health",
        "Blood Health",
        "Vitamins, Minerals & Electrolytes"
    ]

    var sortedBiomarkers: [BiomarkerCategory] {
        viewModel.biomarkers.sorted {
            let firstIndex = orderedCategoryNames.firstIndex(of: $0.name) ?? Int.max
            let secondIndex = orderedCategoryNames.firstIndex(of: $1.name) ?? Int.max
            return firstIndex < secondIndex
        }
    }

    var body: some View {
        HomeSectionView(
            title: "Biomarkers",
            iconName: "testtube.2",
            iconColor: Color.red,
            content: {
                if isLoading {
                    LazyVStack {
                        ProgressView()
                    }
                    .padding()
                } else if showError {
                    LazyVStack(spacing: 12) {
                        Text("There was an error fetching your biomarkers. Please try again or contact support.")
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                do {
                                    showError = false
                                    try await viewModel.fetchBiomarkers()
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else if sortedBiomarkers.isEmpty && isLoadingSilently != true {
                    EmptyStateView(
                        title: "No Biomarker Data",
                        description: "",
                        actions: {EmptyView()}
                    )
                } else {
                    ForEach(sortedBiomarkers) { biomarkerCategory in
                        if let categoryDetails = defaultCategoryOrder[biomarkerCategory.name] {
                            let showWhenEmpty = visibleWhenEmptyCategories.contains(biomarkerCategory.name)
                            if biomarkerCategory.hasSamples {
                                NavigationLink {
                                    BiomarkerCategoryView(category: biomarkerCategory)
                                } label: {
                                    BiomarkerCategoryCardView(
                                        biomarkerCategory: biomarkerCategory,
                                        iconName: categoryDetails.iconName,
                                        iconColor: categoryDetails.color,
                                        hasSamples: true
                                    )
                                }
                                .tint(colorScheme == .dark ? .white : .black)
                            } else if showWhenEmpty {
                                BiomarkerCategoryCardView(
                                    biomarkerCategory: biomarkerCategory,
                                    iconName: categoryDetails.iconName,
                                    iconColor: categoryDetails.color,
                                    hasSamples: false
                                )
                            }
                        }
                    }
                }
            }
        )

        if !viewModel.labTestOrders.isEmpty {
            LabTestOrdersSectionView()
                .environmentObject(viewModel)
                .environmentObject(chatViewModel)
                .environmentObject(tabsViewModel)
        }

        if !viewModel.labTests.isEmpty {
            NavigationLink {
                OrderLabsView()
                    .environmentObject(viewModel)
                    .navigationTitle("Order Labs")
            } label: {
                HStack {
                    Image(systemName: "testtube.2")
                        .font(.system(size: 24))
                        .symbolRenderingMode(.multicolor)
                        .frame(width: 30, alignment: .center)
                    Text("Order Labs")
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSpacing(0)
        }
    }
}

// #Preview {
//    BiomarkersSectionView()
// }

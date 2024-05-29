import SwiftUI
import MarkdownUI

struct LabTestDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: OrderLabTestsViewModel

    let labTest: LabTest

    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

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

    var body: some View {
        ZStack {
            VStack {
                List {
                    Section(header: SectionHeaderView(title: "Details")) {
                        VStack(alignment: .leading) {
                            Markdown(labTest.markdownDescription)
                                .opacity(0.9)
                        }
                    }
                    .listSectionSpacing(10)

                    Section {
                        VStack(spacing: 4) {
                            HStack {
                                Text("Requires Fasting")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(labTest.isFastingRequired ? "Yes" : "No")
                                    .opacity(0.9)
                            }
                        }

                        if let labName = labTest.labName {
                            HStack {
                                Text("Lab Provider")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(labName)
                                    .opacity(0.9)
                            }
                        }

                        HStack {
                            Text("Price")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(labTest.price)
                                .opacity(0.9)
                        }
                    }

                    if let biomarkers = labTest.biomarkers, !biomarkers.isEmpty {
                        Section(header: SectionHeaderView(title: "Biomarkers Included")) {}
                            .headerProminence(.increased)
                            .listSectionSpacing(0)
                            .padding(.top, 16)

                        let groupedByCategory = Dictionary(grouping: biomarkers) { $0.category ?? "Other" }
                        let sortedCategories = orderedCategoryNames.filter { groupedByCategory.keys.contains($0) }
                        let categories = groupedByCategory.keys.contains("Other") ? sortedCategories + ["Other"] : sortedCategories

                        ForEach(categories, id: \.self) { category in
                            Section(header: SectionHeaderView(title: category)) {
                                ForEach(groupedByCategory[category]!, id: \.id) { biomarker in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(biomarker.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        if let description = biomarker.description {
                                            Text(description)
                                                .font(.footnote)
                                                .opacity(0.8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                AppButton(
                    text: "Order \(labTest.name) Test",
                    fullWidth: true,
                    isDisabled: isLoading,
                    isLoading: isLoading
                ) {
                    Task {
                        do {
                            isLoading = true
                            try await viewModel.createCheckout(labTestId: labTest.id)
                            isLoading = false
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                            isLoading = false
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
            }

            if isLoading {
                LoadingOverlayView()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("Ok") {
                showError = false
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $viewModel.showCheckoutPage) {
            NavigationStack {
                if let url = viewModel.checkoutPageUrl {
                    WebView(url: url, onNavigate: viewModel.handleCheckoutNavigation)
                        .toolbar {
                            Button {
                                viewModel.showCheckoutPage = false
                            } label: {
                                Image(systemName: "multiply")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.secondary)
                            }
                        }
                } else {
                    EmptyView()
                        .onAppear {
                            viewModel.showCheckoutPage = false
                            errorMessage = "Something went wrong. Please try again or contact support."
                            showError = true
                        }
                }
            }
        }
        .sheet(isPresented: $viewModel.requiresAdditionalInformation) {
            NavigationStack {
                CollectAdditionalLabOrderInformationView(labTestId: labTest.id)
                    .navigationBarBackButtonHidden()
                    .navigationTitle("Additional Information")
                    .navigationBarTitleDisplayMode(.inline)
                    .environmentObject(viewModel)
                    .interactiveDismissDisabled()
                    .toolbar {
                        Button {
                            viewModel.requiresAdditionalInformation = false
                        } label: {
                            Image(systemName: "multiply")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.secondary)
                        }
                    }
            }
        }
        .navigationDestination(isPresented: $viewModel.showOrderConfirmation) {
            OrderConfirmationView(labTest: labTest)
                .environmentObject(viewModel)
                .toolbar {
                    Button {
                        viewModel.dismissLabTestOrderModal()
                    } label: {
                        Image(systemName: "multiply")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.secondary)
                    }
                }
        }
    }
}

// #Preview {
//    LabTestDetailsView()
// }

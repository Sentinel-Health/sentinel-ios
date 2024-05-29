import SwiftUI

struct AllLabTestOrdersView: View {
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    @StateObject var viewModel: LabTestOrdersViewModel = LabTestOrdersViewModel()

    @State private var searchText = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var showFetchError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        List {
            Section {
                if isLoading {
                    VStack {
                        ProgressView().id(UUID())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .listRowSeparator(.hidden)
                    .listRowBackground(EmptyView())
                } else if showFetchError {
                    VStack {
                        Text("There was an error fetching your orders. Please try again or contact support.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                await fetchOrders()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                } else if viewModel.orders.isEmpty {
                    VStack {
                        Text("No Lab Orders")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 500)
                    .listRowSeparator(.hidden)
                    .listRowBackground(EmptyView())
                } else {
                    ForEach(viewModel.orders) { labTestOrder in
                        LabTestOrderCellView(labTestOrder: labTestOrder)
                            .environmentObject(tabsViewModel)
                            .environmentObject(chatViewModel)
                    }
                }
            }
        }
        .task {
            await fetchOrders()
        }
        .navigationTitle("Lab Test Orders")
        .alert("Error", isPresented: $showError) {
            Button("Ok") {
                showError = false
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }

    func fetchOrders() async {
        do {
            showFetchError = false
            isLoading = true
            try await viewModel.fetchOrders()
            isLoading = false
        } catch {
            isLoading = false
            showFetchError = true
        }
    }
}

#Preview {
    AllLabTestOrdersView()
}

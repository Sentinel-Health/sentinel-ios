import SwiftUI

struct ProceduresSectionView: View {
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
            title: "Procedures",
            iconName: "ivfluid.bag",
            iconColor: Color.indigo,
            content: {
                if isLoading {
                    LazyVStack {
                        ProgressView()
                    }
                    .padding()
                } else if showError {
                    LazyVStack(spacing: 12) {
                        Text("There was an error fetching your procedures. Please try again or contact support.")
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                do {
                                    showError = false
                                    try await homeViewModel.fetchProcedures()
                                } catch {
                                    showError = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    let proceduresToShow = homeViewModel.procedures.prefix(5)
                    ForEach(proceduresToShow) { procedure in
                        ProcedureCellView(procedure: procedure)
                            .environmentObject(homeViewModel)
                            .environmentObject(chatViewModel)
                            .environmentObject(tabsViewModel)
                    }
                    if homeViewModel.procedures.count > 5 {
                        NavigationLink {
                            AllProceduresListView()
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
    ProceduresSectionView()
}

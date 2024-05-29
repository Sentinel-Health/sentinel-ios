import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel: NotificationsViewModel = NotificationsViewModel()
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if isLoading {
                        VStack {
                            ProgressView()
                        }
                        .padding()
                    } else {
                        Section {
                            ForEach(viewModel.notifications) { notification in
                                NotificationCellView(
                                    onTapped: {
                                        AppLogger.instance("UI").debug("notification: \(notification.id) tapped")
                                    }, notification: notification
                                )
                            }
                        }
                    }
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
            .navigationTitle("Notifications")
            .task {
                isLoading = true
                do {
                    try await viewModel.fetchNotifications()
                    isLoading = false
                } catch {
                    isLoading = false
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// #Preview {
//    NotificationsView()
// }

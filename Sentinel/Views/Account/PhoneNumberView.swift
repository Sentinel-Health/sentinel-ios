import SwiftUI
import AlertToast

struct PhoneNumberView: View {
    @EnvironmentObject var formViewModel: PhoneNumberFormViewModel

    var body: some View {
        Form {
            PhoneNumberFormView()
                .environmentObject(formViewModel)
        }
        .toast(isPresenting: $formViewModel.showSuccess) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "Phone Number saved!"
            )
        }
        .onDisappear {
            formViewModel.resetForm()
            Task {
                try await Session.shared.syncUser()
            }
        }
    }
}

#Preview {
    PhoneNumberView()
}

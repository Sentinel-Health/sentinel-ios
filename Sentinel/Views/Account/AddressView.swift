import SwiftUI
import AlertToast

struct AddressView: View {
    @EnvironmentObject var formViewModel: AddressFormViewModel

    var body: some View {
        Form {
            AddressFormView()
                .environmentObject(formViewModel)
        }
        .task {
            await formViewModel.loadUser()
        }
        .toast(isPresenting: $formViewModel.showSuccess) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "Address saved!"
            )
        }
    }
}

#Preview {
    AddressView()
}

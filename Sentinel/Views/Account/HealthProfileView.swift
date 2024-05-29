import SwiftUI
import HealthKit
import AlertToast

struct HealthProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var formViewModel: HealthProfileFormViewModel

    var body: some View {
        Form {
            HealthProfileFormView()
                .environmentObject(formViewModel)
        }
        .toast(isPresenting: $formViewModel.showSuccess) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "Profile saved!"
            )
        }
    }
}

// #Preview {
//    HealthProfileView()
// }

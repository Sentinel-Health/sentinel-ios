import SwiftUI

struct SyncingDataAlertView: View {
    @Environment(\.colorScheme) var colorScheme

    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.clockwise.icloud")
                Text("Syncing Data")
                    .font(.headline)

                Spacer()
                if let onDismiss = self.onDismiss {
                    Button(action: onDismiss, label: {
                        Image(systemName: "multiply")
                    })
                    .buttonStyle(.plain)
                    .accentColor(.primary)
                    .opacity(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            Divider()
            VStack(spacing: 4) {
                Text("We're currently syncing your health data. While syncing, some features and data may not be available. This may take some time depending on how much data you have. The data will continue to sync in the background while your phone is unlocked.")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    SyncingDataAlertView()
        .padding()
}

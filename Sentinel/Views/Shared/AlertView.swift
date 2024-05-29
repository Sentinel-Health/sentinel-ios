import SwiftUI

struct AlertView: View {
    @Environment(\.colorScheme) var colorScheme

    var alert: AlertViewContent
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "bell.badge")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .primary)
                Text(alert.title)
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
            if let action = alert.action {
                Button(action: action, label: {
                    AlertMessageContentView(isButton: true, message: alert.message)
                })
                .buttonStyle(.plain)
                .accentColor(.primary)
            } else {
                AlertMessageContentView(isButton: false, message: alert.message)
            }

        }
    }
}

struct AlertMessageContentView: View {
    let isButton: Bool
    let message: String

    var body: some View {
        HStack(spacing: 4) {
            Text(message)
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            if isButton {
                Image(systemName: "chevron.forward")
                    .opacity(0.5)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

 #Preview {
    AlertView(alert: AlertViewContent(
        title: "Hello world!",
        message: "This is just a test of the broadcast alert system."
    ))
    .padding()
 }

import SwiftUI

struct NotificationCellView: View {
    @Environment(\.colorScheme) var colorScheme
    var onTapped: () -> Void

    let notification: UserNotification

    var body: some View {
        HStack(alignment: .top) {
            if !notification.read {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                    .padding(.top, 2)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 12, height: 12)
                    .padding(.top, 2)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if let title = notification.title {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text(dateString(isoStringToDate(notification.createdAt) ?? Date(), style: .medium))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text(notification.body)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                onTapped()
            }
        }
    }
}

// #Preview {
//    NotificationCellView()
// }

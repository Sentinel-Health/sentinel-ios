import SwiftUI

struct EmptyStateView<Content: View>: View {
    var title: String?
    var iconName: String?
    var description: String
    @ViewBuilder var actions: () -> Content

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.secondary)
            }
            if let title = title {
                Text(title)
                    .font(.headline)
            }
            Text(description)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            actions()
        }
        .padding()
    }
}

#Preview {
    EmptyStateView(
        title: "It's Empty!",
        iconName: "tray",
        description: "Looks a little empty around here!",
        actions: {EmptyView()}
    )
}

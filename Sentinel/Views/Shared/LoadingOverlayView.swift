import SwiftUI

struct LoadingOverlayView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(.gray)
                .opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            VStack {
                ProgressView()
                    .tint(.secondary)
            }
            .padding(30)
            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
            .cornerRadius(15)
            .shadow(color: colorScheme == .dark ? Color(UIColor.systemGray2) : .gray, radius: 5, x: 0, y: 10)
        }
    }
}

#Preview {
    LoadingOverlayView()
}

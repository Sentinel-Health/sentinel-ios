import SwiftUI

struct SyncChangesFullScreenCoverView: View {
    var body: some View {
        VStack {
            Text("Please wait while we sync some changes, this should only take a few seconds.")
                .multilineTextAlignment(.center)
                .padding()
            ProgressView()
        }
        .padding()
    }
}

#Preview {
    SyncChangesFullScreenCoverView()
}

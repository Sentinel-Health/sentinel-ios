import SwiftUI

struct AppLaunchView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image("icon")
                    .resizable()
                    .frame(width: 128, height: 129)
                    .padding(.horizontal)
                ProgressView()
                    .tint(.white)
            }
        }
    }
}

#Preview {
    AppLaunchView()
}

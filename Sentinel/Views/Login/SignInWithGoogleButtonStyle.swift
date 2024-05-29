import SwiftUI

struct SignInWithGoogleButtonStyle: ButtonStyle {

    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image("GoogleIcon")
                .resizable()
                .frame(width: 18, height: 18)

            configuration
                .label
                .font(.system(size: 19, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(colorScheme == .dark ? .white : .black)
        .foregroundColor(colorScheme == .dark ? .black : .white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    Button {

    } label: {
        Text("Continue with Google")
    }
    .buttonStyle(SignInWithGoogleButtonStyle())
}

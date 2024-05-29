import SwiftUI

extension Button {
    func buttonStyle(
        backgroundColor: Color = .black,
        foregroundColor: Color = .white,
        fullWidth: Bool = false,
        isDisabled: Bool = false,
        isLoading: Bool = false
    ) -> some View {
        self
            .padding()
            .disabled(isDisabled || isLoading)
            .foregroundColor(foregroundColor)
            .fontWeight(.semibold)
            .background(backgroundColor)
            .opacity(isDisabled || isLoading ? 0.8 : 1.0)
            .cornerRadius(10)
    }
}

struct AppButton: View {
    @Environment(\.colorScheme) var colorScheme

    var text: String
    var fullWidth: Bool = false
    var isDisabled: Bool = false
    var isLoading: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .padding(.trailing, 4)
                        .tint(colorScheme == .dark ? .black : .white)
                }
                Text(text)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .center)
        }
        .buttonStyle(
            backgroundColor: colorScheme == .dark ? .white : .black,
            foregroundColor: colorScheme == .dark ? .black : .white,
            fullWidth: fullWidth,
            isDisabled: isDisabled,
            isLoading: isLoading
        )
    }
}

#Preview {
    AppButton(
        text: "Hello, world",
        fullWidth: false,
        isDisabled: false,
        isLoading: false,
        action: {
            AppLogger.instance("UI").debug("Hello, world")
        }
    )
}

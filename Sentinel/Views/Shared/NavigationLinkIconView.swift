import SwiftUI

struct NavigationLinkIconView: View {
    var body: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 14))
            .bold()
            .opacity(0.25)
    }
}

#Preview {
    NavigationLinkIconView()
}

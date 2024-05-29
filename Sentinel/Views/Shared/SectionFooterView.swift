import SwiftUI

struct SectionFooterView: View {
    let text: String

    var body: some View {
        HStack {
            Text(.init(text))
                .textCase(.none)
        }
        .listRowInsets(.init(top: 4, leading: 16, bottom: 8, trailing: 16))
    }
}

#Preview {
    SectionHeaderView(title: "Section Footer")
}

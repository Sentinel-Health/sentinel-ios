import SwiftUI

struct SectionHeaderView: View {
    let title: String

    var body: some View {
        if title == "" {
            EmptyView()
        } else {
            HStack {
                Text(title)
                    .textCase(.none)
                    .bold()
            }
            .listRowInsets(.init(top: 8, leading: 0, bottom: 4, trailing: 0))
        }
    }
}

#Preview {
    SectionHeaderView(title: "Section Header")
}

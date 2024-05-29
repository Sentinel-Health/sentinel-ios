import SwiftUI

struct HomeSectionView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var sheetContentHeight = CGFloat(0)

    let title: String
    let iconName: String
    let iconColor: Color?
    let content: Content

    init(title: String, iconName: String, iconColor: Color = .blue, @ViewBuilder content: () -> Content) {
        self.title = title
        self.iconName = iconName
        self.iconColor = iconColor
        self.content = content()
    }

    var body: some View {
        Section(header: SectionHeaderView(title: title)) {
            content
        }
        .headerProminence(.increased)
    }
}

// #Preview {
//    HomeSection()
// }

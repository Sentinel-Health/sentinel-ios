import SwiftUI

struct BiomarkerCategoryCardView: View {
    @Environment(\.colorScheme) var colorScheme

    let biomarkerCategory: BiomarkerCategory
    let iconName: String
    let iconColor: Color
    let hasSamples: Bool

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .frame(width: 30, alignment: .center)
                .foregroundStyle(iconColor)

            HStack {
                Text(biomarkerCategory.name)
                Spacer()
                if hasSamples {
                    let status = biomarkerCategory.biomarkerStatus()
                    HStack {
                        Image(systemName: status.iconName)
                            .foregroundColor(status.color)
                    }
                } else {
                    HStack {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// #Preview {
//    BiomarkerCategoryCardView()
// }

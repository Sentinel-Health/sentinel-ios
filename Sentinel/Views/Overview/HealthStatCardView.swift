import SwiftUI

struct HealthStatCardView: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    let icon: Image
    let iconColor: Color
    let statText: String
    let statUnitText: String?
    let statDateString: String?
    let statDescription: String?
    let trendStat: String?

    var body: some View {
        cardContent
            .padding(.bottom, 8)
            .listRowSeparator(.hidden)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 10)
                    .background(.clear)
                    .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                    .padding(
                        EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 8,
                            trailing: 0
                        )
                    )
            )
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                icon
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .default))

                Spacer()

                if let statDate = statDateString, let date = isoStringToDate(statDate) {
                    Text(formatRelativeDate(date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .bottom, spacing: 3) {
                        Text(statText)
                            .font(.system(size: 28, weight: .bold, design: .rounded))

                        if let statUnitText = statUnitText {
                            Text(statUnitText)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 4)
                        }
                    }

                    if let trendStat = trendStat {
                        Text(trendStat)
                            .font(.system(size: 15, weight: .light, design: .rounded))
                            .foregroundStyle(.secondary)

                    }
                }

                Spacer()

                // TODO: put a non-interactive chart here
            }
        }
    }
}

// #Preview {
//     HealthStatCardView()
// }

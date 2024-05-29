import SwiftUI

struct LabTestOrderCellView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    let labTestOrder: LabTestOrder

    var body: some View {
        NavigationLink {
            LabTestOrderDetailsView(labTestOrder: labTestOrder)
                .navigationTitle("Lab Test Order")
                .environmentObject(tabsViewModel)
                .environmentObject(chatViewModel)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(labTestOrder.labTest.name)
                        .font(.headline)

                if let orderedOn = isoStringToDate(labTestOrder.createdAt) {
                    Text("Ordered on: \(dateString(orderedOn, style: .medium))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Image(systemName: labTestOrder.statusIconName)
                        .foregroundStyle(labTestOrder.statusColor)
                    Text(labTestOrder.statusLabel)
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(labTestOrder.statusColor)
                }
            }
        }
    }
}

// #Preview {
//    LabTestOrderCellView()
// }

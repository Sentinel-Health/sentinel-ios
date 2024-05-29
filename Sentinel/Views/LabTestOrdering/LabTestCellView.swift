import SwiftUI

struct LabTestCellView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: OrderLabTestsViewModel = OrderLabTestsViewModel()

    let labTest: LabTest

    var body: some View {
        Button {
            viewModel.toggleLabTestOrderModal()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text(labTest.name)
                    .font(.headline)

                Text(labTest.shortDescription)
                    .font(.subheadline)
                    .opacity(0.8)

                Divider()

                HStack {
                    Text("Price")
                    Spacer()
                    Text(labTest.price)
                        .font(.system(.callout, weight: .semibold))

                }
            }
        }
        .foregroundStyle(colorScheme == .dark ? .white : .black)
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
        .sheet(isPresented: $viewModel.showLabTestOrderModal, onDismiss: {
            viewModel.reset()
        }) {
            NavigationStack {
                LabTestDetailsView(labTest: labTest)
                    .navigationTitle(labTest.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        Button {
                            viewModel.toggleLabTestOrderModal()
                        } label: {
                            Image(systemName: "multiply")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.secondary)
                        }
                    }
                    .environmentObject(viewModel)
            }
        }
    }
}

// #Preview {
//    LabTestCellView()
// }

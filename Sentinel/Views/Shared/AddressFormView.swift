import SwiftUI

struct AddressFormView: View {
    @EnvironmentObject var viewModel: AddressFormViewModel

    var body: some View {
        Section(footer: SectionFooterView(text: "Your address is required to verify services are available in your area.")) {
            LabeledContent {
                TextField("Address Line 1", text: $viewModel.street1)
                    .textContentType(.streetAddressLine1)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.next)
            } label: {
                Text("Street")
            }

            LabeledContent {
                TextField("Address Line 2", text: $viewModel.street2)
                    .textContentType(.streetAddressLine2)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.next)
            } label: {
                Text("Street 2")
            }

            LabeledContent {
                TextField("City", text: $viewModel.city)
                    .textContentType(.addressCity)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.next)
            } label: {
                Text("City")
            }

            LabeledContent {
                Picker("", selection: $viewModel.state) {
                    Text("Select").opacity(0.5).disabled(true).tag("")
                    ForEach(USState.allCases) { state in
                        Text("\(state.rawValue)")
                            .tag(state)
                    }
                }
                .tint(.primary)
                .foregroundStyle(.primary)
            } label: {
                Text("State")
            }

            LabeledContent {
                TextField("Zip code", text: $viewModel.zipCode)
                    .textContentType(.postalCode)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
            } label: {
                Text("Zip Code")
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorModal) {
            Button("Ok") {
                viewModel.showErrorModal = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    AddressFormView()
}

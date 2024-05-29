import SwiftUI

struct HealthProfileFormView: View {
    @EnvironmentObject var viewModel: HealthProfileFormViewModel

    var fieldBackgroundColor: Color?

    @FocusState private var focusedField: Field?

    let startDate: Date = Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
    let endDate: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()

    enum Field {
        case firstName, lastName, sex, dateOfBirth, bloodType
    }

    var body: some View {
        Section {
            LabeledContent {
                TextField("Enter Name", text: $viewModel.firstName)
                    .focused($focusedField, equals: .firstName)
                    .textContentType(.givenName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .lastName
                    }
                    .multilineTextAlignment(.trailing)
            } label: {
                Text("Legal First Name")
            }
            .listRowBackground(fieldBackgroundColor)

            LabeledContent {
                TextField("Enter Name", text: $viewModel.lastName)
                    .focused($focusedField, equals: .lastName)
                    .textContentType(.familyName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .sex
                    }
                    .multilineTextAlignment(.trailing)
            } label: {
                Text("Legal Last Name")
            }
            .listRowBackground(fieldBackgroundColor)

            LabeledContent {
                Picker("", selection: $viewModel.sex) {
                    Text("Select").tag("")
                    ForEach(sexOptions, id: \.self) { sex in
                        Text("\(sex.description)").tag(sex.description)
                    }
                }
                .tint(.primary)
            } label: {
                Text("Biological Sex")
            }
            .listRowBackground(fieldBackgroundColor)

            LabeledContent("Date of Birth") {
                DatePicker("", selection: $viewModel.dob, in: startDate...endDate, displayedComponents: .date)
            }
            .listRowBackground(fieldBackgroundColor)

            LabeledContent {
                Picker("", selection: $viewModel.bloodType) {
                    Text("Select").tag("")
                    ForEach(bloodTypeOptions, id: \.self) { bloodType in
                        Text("\(bloodType.description)").tag(bloodType.description)
                    }
                }
                .tint(.primary)
            } label: {
                Text("Blood Type")
            }
            .listRowBackground(fieldBackgroundColor)
        }
        .headerProminence(.increased)
        .task {
            do {
                viewModel.isLoading = true
                try await viewModel.fetchHealthProfile()
                if let healthProfile = viewModel.healthProfile {
                    viewModel.firstName = healthProfile.legalFirstName ?? ""
                    viewModel.lastName = healthProfile.legalLastName ?? ""
                    if let dobString = healthProfile.dob {
                        if let date = isoStringToDate(dobString) {
                            viewModel.dob = date
                        }
                    }
                    // convert certain fields to capitalized versions when data is stored lowercased
                    viewModel.sex = healthProfile.sex?.capitalized ?? ""
                    viewModel.bloodType = healthProfile.bloodType ?? ""
                }
                viewModel.isLoading = false
            } catch {
                viewModel.errorMessage = error.localizedDescription
                viewModel.showErrorModal = true
                viewModel.isLoading = false
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
    HealthProfileFormView()
}

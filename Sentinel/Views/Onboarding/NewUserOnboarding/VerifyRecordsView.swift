import SwiftUI

struct VerifyRecordsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: VerifyRecordsViewModel = VerifyRecordsViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel

    @State var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "list.clipboard")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 32))
                        Text("Verify Records")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 16)

                Text("Take a minute to verify the information we have is correct. Don't worry, you can always update or add things later.")
                    .opacity(0.9)
                    .padding(.bottom, 12)

                Text("*Archiving something below tells Sentinel it's no longer relevant to you, but it will still remain in your records.")
                    .opacity(0.8)
                    .font(.system(size: 14))
                    .padding(.bottom, 12)
            }
            .padding(.horizontal)
            .padding(.top, 40)

            List {
                if isLoading {
                    VStack(alignment: .center) {
                        ProgressView()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .listRowBackground(EmptyView())
                } else {
                    Section(header: Text("Medical Conditions")) {
                        if viewModel.conditions.isEmpty {
                            EmptyStateView(description: "No Medical Conditions", actions: {EmptyView()})
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(viewModel.conditions) { condition in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(condition.name)
                                        if let recentHistory = condition.mostRecentHistory() {
                                            if let recordedOn = recentHistory.recordedOn {
                                                if let date = isoStringToDate(recordedOn) {
                                                    Text("Recorded on: \(dateString(date))")
                                                        .font(.caption)
                                                }
                                            }
                                            if let recordedBy = recentHistory.recordedBy {
                                                Text("Recorded by: \(recordedBy)")
                                                    .font(.caption)
                                            }
                                            if let source = recentHistory.source {
                                                Text("Source: \(source)")
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    Spacer()
                                    Button("Archive") {
                                        Task {
                                            try await viewModel.archiveCondition(condition.id)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)

                    Section(header: Text("Medications")) {
                        if viewModel.medications.isEmpty {
                            EmptyStateView(description: "No Medications", actions: {EmptyView()})
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(viewModel.medications) { medication in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(medication.name)
                                        if let authoredOn = medication.authoredOn {
                                            if let date = isoStringToDate(authoredOn) {
                                                Text("Authored on: \(dateString(date))")
                                                    .font(.caption)
                                            }
                                        }
                                        if let authoredBy = medication.authoredBy {
                                            Text("Authored by: \(authoredBy)")
                                                .font(.caption)
                                        }
                                        if let source = medication.source {
                                            Text("Source: \(source)")
                                                .font(.caption)
                                        }
                                    }
                                    Spacer()
                                    Button("Archive") {
                                        Task {
                                            try await viewModel.archiveMedication(medication.id)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)

                    Section(header: Text("Allergies")) {
                        if viewModel.allergies.isEmpty {
                            EmptyStateView(description: "No Allergies", actions: {EmptyView()})
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(viewModel.allergies) { allergy in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(allergy.name)
                                        if let recordedOn = allergy.recordedOn {
                                            if let date = isoStringToDate(recordedOn) {
                                                Text("Recorded on: \(dateString(date))")
                                                    .font(.caption)
                                            }
                                        }
                                        if let source = allergy.source {
                                            Text("Source: \(source)")
                                                .font(.caption)
                                        }
                                    }
                                    Spacer()
                                    Button("Archive") {
                                        Task {
                                            try await viewModel.archiveAllergy(allergy.id)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)

                    Section(header: Text("Vaccines")) {
                        if viewModel.immunizations.isEmpty {
                            EmptyStateView(description: "No Vaccines", actions: {EmptyView()})
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(viewModel.immunizations) { immunization in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(immunization.name)
                                        if let receivedOn = immunization.receivedOn {
                                            if let date = isoStringToDate(receivedOn) {
                                                Text("Received on: \(dateString(date))")
                                                    .font(.caption)
                                            }
                                        }
                                        if let source = immunization.source {
                                            Text("Source: \(source)")
                                                .font(.caption)
                                        }
                                    }
                                    Spacer()
                                    Button("Archive") {
                                        Task {
                                            try await viewModel.archiveImmunization(immunization.id)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)

                    Section(header: Text("Procedures")) {
                        if viewModel.procedures.isEmpty {
                            EmptyStateView(description: "No Procedures", actions: {EmptyView()})
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(viewModel.procedures) { procedure in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(procedure.name)
                                        if let performedOn = procedure.performedOn {
                                            if let date = isoStringToDate(performedOn) {
                                                Text("Performed on: \(dateString(date))")
                                                    .font(.caption)
                                            }
                                        }
                                        if let source = procedure.source {
                                            Text("Source: \(source)")
                                                .font(.caption)
                                        }
                                    }
                                    Spacer()
                                    Button("Archive") {
                                        Task {
                                            try await viewModel.archiveProcedure(procedure.id)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollBounceBehavior(.basedOnSize)

            VStack {
                AppButton(
                    text: "Continue",
                    fullWidth: true,
                    action: {
                        withAnimation {
                            onboardingViewModel.nextView()
                        }
                    }
                )
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .task {
            isLoading = true
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    do {
                        try await viewModel.fetchConditions()
                    } catch {
                        // Handle any errors that occurred in any of the tasks
                    }
                }
                group.addTask {
                    do {
                        try await viewModel.fetchMedications()
                    } catch {
                    }
                }
                group.addTask {
                    do {
                        try await viewModel.fetchAllergies()
                    } catch {
                    }
                }
                group.addTask {
                    do {
                        try await viewModel.fetchImmunizations()
                    } catch {
                    }
                }
                group.addTask {
                    do {
                        try await viewModel.fetchProcedures()
                    } catch {
                    }
                }
            }
            isLoading = false
        }
    }
}

// #Preview {
//    VerifyRecordsView()
// }

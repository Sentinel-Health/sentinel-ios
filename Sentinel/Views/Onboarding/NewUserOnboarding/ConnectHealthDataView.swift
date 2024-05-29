import SwiftUI
import MarkdownUI

struct ConnectHealthDataView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var hasConnectedAppleHealth: Bool = false
    @State private var hasConnectedHealthRecords: Bool = false

    var hasConnectedData: Bool {
        return hasConnectedAppleHealth
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Connect your data")
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        .padding(.bottom, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Great! Now, in order for us to deliver a personalized health experience for you, we need access to your health data.")
                                .opacity(0.9)
                            Markdown("**How we use your data:**\n- To show personal data highlights\n- To give you personalized recommendations\n- To better answer your health questions more accurately")
                                .opacity(0.9)
                        }
                        .padding(.bottom, 16)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Data Sources")
                                .font(.headline)

                            Divider()

                            VStack {
                                Button(action: {
                                    Task {
                                        do {
                                            try await HealthKitService.shared.requestClinicalRecordsPermission()
                                            await AppState.shared.authorizedHealthRecords()
                                            hasConnectedHealthRecords = true
                                        } catch {
                                            showError = true
                                            errorMessage = error.localizedDescription
                                        }
                                        await HealthKitService.shared.syncClinicalRecordsData()
                                    }
                                }, label: {
                                    HStack {
                                        Text("📋")
                                            .font(.system(size: 20))
                                            .frame(width: 24, alignment: .center)
                                        HStack {
                                            Text("Connect Health Records")
                                                .multilineTextAlignment(.leading)
                                                .fontWeight(.medium)
                                            if hasConnectedHealthRecords {
                                                Spacer()
                                                Image(systemName: "checkmark.circle")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                })
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .tint(colorScheme == .dark ? .white : .black)
                                .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                .disabled(hasConnectedHealthRecords)
                            }

                            Button(action: {
                                Task {
                                    do {
                                        try await HealthKitService.shared.requestHealthKitPermission()
                                        await AppState.shared.authorizedHealthKit()
                                        hasConnectedAppleHealth = true
                                    } catch {
                                        showError = true
                                        errorMessage = error.localizedDescription
                                    }

                                    await HealthKitService.shared.syncHealthData(fullRefresh: true, numberOfMonthsBack: 12)
                                }
                            }, label: {
                                HStack {
                                    Image("Apple Health Icon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                        .frame(width: 24, alignment: .center)
                                    HStack {
                                        Text("Connect Apple Health")
                                            .multilineTextAlignment(.leading)
                                            .fontWeight(.medium)
                                        if hasConnectedAppleHealth {
                                            Spacer()
                                            Image(systemName: "checkmark.circle")
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .tint(colorScheme == .dark ? .white : .black)
                            .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .disabled(hasConnectedAppleHealth)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal)
                    Spacer()
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                .padding(.top, 1)
            }
            VStack {
                AppButton(
                    text: "Continue",
                    fullWidth: true,
                    isDisabled: (hasConnectedData == false && hasConnectedHealthRecords == false),
                    action: {
                        withAnimation {
                            onboardingViewModel.nextView()
                        }
                    }
                )
            }
            .padding()
        }
        .alert("Error", isPresented: $showError) {
            Button("Ok") {
                showError = false
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    ConnectHealthDataView()
}

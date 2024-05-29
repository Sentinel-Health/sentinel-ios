import SwiftUI

struct ConnectAppleHealthView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var onboardingViewModel: DeviceOnboardingViewModel

    @State private var hasConnectedHealthRecords: Bool = false
    @State private var hasConnectedAppleHealth: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        VStack(spacing: 16) {
                            Image("Apple Health Icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .shadow(color: Color(UIColor.systemGray), radius: 1)
                                .frame(width: 75, height: 75)
                            Text("Connect to Apple Health")
                                .font(.title)
                                .bold()
                            Text("Connect your account to Apple Health on this device to sync your health data. For the best experience, we recommend authorizing both your health records and health data.")
                                .opacity(0.9)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }

                        Divider()
                            .padding(.vertical)

                        VStack(spacing: 16) {
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
                                        Image(systemName: "heart.text.square")
                                            .font(.system(size: 20))
                                            .frame(width: 24, alignment: .center)
                                        HStack {
                                            Text("Authorize Health Records")
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
                                    Image(systemName: "figure.run")
                                        .font(.system(size: 20))
                                        .frame(width: 24, alignment: .center)
                                    HStack {
                                        Text("Authorize Health Data")
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
            }

            VStack(spacing: 20) {
                AppButton(
                    text: "Continue",
                    fullWidth: true,
                    isDisabled: (hasConnectedAppleHealth == false && hasConnectedHealthRecords == false),
                    action: {
                        withAnimation {
                            onboardingViewModel.nextView()
                        }
                    }
                )
                Button("Skip for Now") {
                    withAnimation {
                        onboardingViewModel.nextView()
                    }
                }
                .font(.callout)
                .tint(colorScheme == .dark ? .white : .black)
            }
            .padding()
        }
    }
}

#Preview {
    ConnectAppleHealthView()
}

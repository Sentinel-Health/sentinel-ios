import SwiftUI
import HealthKit

struct AccountListView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var tabsViewModel: TabsViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    @StateObject var viewModel: AccountViewModel = AccountViewModel()
    @StateObject var healthFormViewModel: HealthProfileFormViewModel = HealthProfileFormViewModel()
    @StateObject var addressFormViewModel: AddressFormViewModel = AddressFormViewModel()
    @StateObject var phoneNumberFormViewModel: PhoneNumberFormViewModel = PhoneNumberFormViewModel()

    @State private var isShowingLogOutConfirmation: Bool = false
    @State private var arePushNotificationsEnabled: Bool = UserDefaults.standard.bool(forKey: HAS_ENABLED_PUSH_NOTIFICATIONS_KEY)
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isDailyCheckinEnabled: Bool = true

    var body: some View {
        VStack {
            GeometryReader { geometry in
                List {
                    Section {
                        if let user = Session.shared.currentUser {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .frame(width: 45, alignment: .center)
                                    .foregroundStyle(.secondary)
                                VStack(alignment: .leading) {
                                    if let fullName = user.fullName {
                                        Text(fullName)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Text(user.email)
                                }
                            }

                            HStack {
                                NavigationLink {
                                    PhoneNumberView()
                                        .environmentObject(phoneNumberFormViewModel)
                                        .navigationTitle("Phone Number")
                                        .navigationBarTitleDisplayMode(.inline)
                                } label: {
                                    Image(systemName: "phone")
                                        .frame(width: 24, alignment: .center)
                                    Text("Phone Number")
                                    if let phoneNumber = user.phoneNumber {
                                        Text(phoneNumber)
                                            .foregroundStyle(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .lineLimit(1)
                                    } else {
                                        Text("N/A")
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .opacity(0.3)
                                    }
                                }
                            }

                            HStack {
                                NavigationLink {
                                    AddressView()
                                        .environmentObject(addressFormViewModel)
                                        .navigationTitle("Address")
                                        .navigationBarTitleDisplayMode(.inline)
                                        .toolbar {
                                            Button {
                                                Task {
                                                    await addressFormViewModel.submitForm()
                                                }
                                            } label: {
                                                if addressFormViewModel.isLoading {
                                                    ProgressView()
                                                } else {
                                                    Text("Save")
                                                }
                                            }
                                        }
                                } label: {
                                    Image(systemName: "mail")
                                        .frame(width: 24, alignment: .center)
                                    Text("Address")
                                    if let addressString = user.addressString {
                                        Text(addressString)
                                            .foregroundStyle(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .lineLimit(1)
                                    } else {
                                        Text("N/A")
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .opacity(0.3)
                                    }
                                }
                            }
                        }

                        NavigationLink {
                            HealthProfileView()
                                .environmentObject(healthFormViewModel)
                                .navigationTitle("Health Profile")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    Button {
                                        Task {
                                            await healthFormViewModel.submitForm()
                                        }
                                    } label: {
                                        if healthFormViewModel.isLoading {
                                            ProgressView()
                                        } else {
                                            Text("Save")
                                        }
                                    }
                                }
                        } label: {
                            Image(systemName: "heart.text.square")
                                .frame(width: 24, alignment: .center)
                            Text("Health Profile")
                        }
                    }

                    Section(header: SectionHeaderView(title: "Notifications")) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .frame(width: 24, alignment: .center)
                            Toggle(isOn: $arePushNotificationsEnabled) {
                                Text("Push Notifications")
                            }
                            .tint(.green)
                            .onChange(of: arePushNotificationsEnabled) {
                                if arePushNotificationsEnabled {
                                    AppState.shared.enablePushNotifications(provisional: false)
                                } else {
                                    UserDefaults.standard.set(false, forKey: HAS_ENABLED_PUSH_NOTIFICATIONS_KEY)
                                    Task {
                                        await AppState.shared.disablePushNotifications()
                                    }
                                }
                            }
                        }

                        HStack {
                            Image(systemName: "bubble")
                                .frame(width: 24, alignment: .center)
                            Toggle(isOn: $isDailyCheckinEnabled) {
                                Text("Daily Check-in")
                            }
                            .tint(.green)
                            .onChange(of: isDailyCheckinEnabled) {
                                Task {
                                    do {
                                        try await viewModel.updateUserNotificationSettings(notificationSettings: [
                                            "notification_settings": [
                                                "daily_checkin": isDailyCheckinEnabled
                                            ]
                                        ])
                                        try await Session.shared.syncUser()
                                    } catch {
                                        showError = true
                                        errorMessage = error.localizedDescription
                                    }
                                }
                            }
                        }
                    }

                    Section(header: SectionHeaderView(title: "Orders")) {
                        NavigationLink {
                            AllLabTestOrdersView()
                                .navigationTitle("Lab Test Orders")
                                .environmentObject(tabsViewModel)
                                .environmentObject(chatViewModel)
                        } label: {
                            HStack {
                                Image(systemName: "testtube.2")
                                    .frame(width: 24, alignment: .center)
                                Text("Lab Test Orders")
                            }
                        }
                    }

                    Section(header: SectionHeaderView(title: "Data Connections")) {
                        NavigationLink {
                            AppleHealthConnectionDetailsView()
                                .navigationTitle("Apple Health")
                        } label: {
                            HStack {
                                Image("Apple Health Icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .frame(width: 24, alignment: .center)
                                    .shadow(color: .gray, radius: 0.5, x: 0, y: 0)
                                Text("Apple Health")
                            }
                        }
                    }

                    Section(header: SectionHeaderView(title: "Support")) {
                        Button(action: {
                            if let url = URL(string: "mailto:support@\(HOST)") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                    .frame(width: 24, alignment: .center)
                                Text("Email Support")
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        }

                        Button(action: {
                            if let url = URL(string: "mailto:feedback@\(HOST)") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }) {
                            HStack {
                                Image(systemName: "lightbulb.max")
                                    .frame(width: 24, alignment: .center)
                                Text("Share your feedback")
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }

                    Section(header: SectionHeaderView(title: "Legal")) {
                        Button(action: {
                            if let url = URL(string: "\(MARKETING_WEBSITE_BASE_URL)/privacy") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }) {
                            HStack {
                                Image(systemName: "lock")
                                    .frame(width: 24, alignment: .center)
                                Text("Privacy Policy")
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        }

                        Button(action: {
                            if let url = URL(string: "\(MARKETING_WEBSITE_BASE_URL)/terms") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }) {
                            HStack {
                                Image(systemName: "newspaper")
                                    .frame(width: 24, alignment: .center)
                                Text("Terms of Service")
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        }

                        Button(action: {
                            if let url = URL(string: "\(MARKETING_WEBSITE_BASE_URL)/hipaa-authorization") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }) {
                            HStack {
                                Image(systemName: "pencil.and.list.clipboard")
                                    .frame(width: 24, alignment: .center)
                                Text("HIPAA Authorization")
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        }

                        Button(action: {
                            if let url = URL(string: "\(MARKETING_WEBSITE_BASE_URL)/telehealth-terms") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }) {
                            HStack {
                                Image(systemName: "stethoscope")
                                    .frame(width: 24, alignment: .center)
                                Text("Telehealth Consent Terms")
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
#if DEV
                    Section(header: SectionHeaderView(title: "Developer")) {
                        Button("Reset Device Onboarding") {
                            tabsViewModel.changeTab("chat")
                            rootViewModel.resetDeviceOnboarding()
                        }.foregroundStyle(.blue)
                        Button("Reset User Onboarding") {
                            tabsViewModel.changeTab("chat")
                            Task {
                                await rootViewModel.resetOnboarding()
                            }
                        }.foregroundStyle(.blue)
                    }
#endif

                    Section {
                        HStack {
                            Spacer()
                            Button("Log Out") {
                                isShowingLogOutConfirmation = true
                            }.foregroundStyle(.red)
                            Spacer()
                        }
                    }
                }
                .task {
                    do {
                        try await Session.shared.syncUser()
                    } catch {
                        showError = true
                        errorMessage = error.localizedDescription
                    }
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
                .confirmationDialog("Log Out Confirmation", isPresented: $isShowingLogOutConfirmation, actions: {
                    Button("Yes", role: .destructive) {
                        Task {
                            await Session.shared.signOut()
                            isShowingLogOutConfirmation = false
                        }
                    }

                    Button("No", role: .cancel) {
                        isShowingLogOutConfirmation = false
                    }
                }) {
                    Text("Are you sure you want to log out?")
                }
                .onReceive(Session.shared.$currentUser) { user in
                    if let user = user {
                        arePushNotificationsEnabled = user.notificationSettings.enabledPushNotifications
                        isDailyCheckinEnabled = user.notificationSettings.dailyCheckin
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
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

// #Preview {
//     AccountListView()
//         .environmentObject(RootViewModel())
// }

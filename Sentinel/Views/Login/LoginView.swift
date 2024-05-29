import SwiftUI
import Combine
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var isLoggingIn = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private let iconDimension: CGFloat = 40

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack(spacing: 8) {
                        VStack(spacing: 16) {
                            Image("icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .shadow(color: Color(UIColor.systemGray), radius: 1)
                                .frame(width: 60, height: 60)
                            Text("Welcome to Sentinel")
                                .font(.title)
                                .bold()
                        }
                        Text("A personal healthcare assistant.")
                            .font(.title3)
                            .opacity(0.9)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .top, spacing: 24) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .symbolRenderingMode(.hierarchical)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconDimension, height: iconDimension)
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Personalized health assistant")
                                    .font(.headline)
                                Text("Can help you understand your health data and records, create personalized health plans, and even generate questions for your doctor.")
                                    .opacity(0.8)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal)

                        HStack(alignment: .top, spacing: 24) {
                            Image(systemName: "waveform.path.ecg.rectangle")
                                .symbolRenderingMode(.multicolor)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconDimension, height: iconDimension)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("All of your health data in one place")
                                    .font(.headline)
                                Text("See all of your health data in one place, including your health records, device data, and more.")
                                    .opacity(0.8)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal)

                        HStack(alignment: .top, spacing: 24) {
                            Image(systemName: "testtube.2")
                                .symbolRenderingMode(.multicolor)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconDimension, height: iconDimension)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Order Lab Tests")
                                    .font(.headline)
                                Text("Get more insights into your health by ordering lab tests that cover a variety of biomarkers.")
                                    .opacity(0.8)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal)

                        HStack(alignment: .top, spacing: 24) {
                            Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                                .symbolRenderingMode(.palette)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconDimension, height: iconDimension)
                                .foregroundStyle(.green, .primary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Secure and private")
                                    .font(.headline)
                                Text("Fully HIPAA compliant. All of your health data and conversations are encrypted and kept private.")
                                    .opacity(0.8)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    .padding(.horizontal)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 1)
                .scrollBounceBehavior(.basedOnSize)

                VStack(spacing: 12) {
                    SignInWithAppleButton(
                        .continue,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                // Handle successful authentication
                                switch authResults.credential {
                                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                    // Extract token and user data
                                    let userIdentifier = appleIDCredential.user
                                    let identityToken = appleIDCredential.identityToken
                                    var name: String = ""

                                    if let fullName = appleIDCredential.fullName {
                                        var nameComponents: [String] = []
                                        if let givenName = fullName.givenName {
                                            nameComponents.append(givenName)
                                        }

                                        if let familyName = fullName.familyName {
                                            nameComponents.append(familyName)
                                        }

                                        if nameComponents.count > 0 {
                                            name = nameComponents.joined(separator: " ")
                                        }
                                    }

                                    Task {
                                        do {
                                            isLoggingIn = true
                                            try await Session.shared.loginWithApple(
                                                userIdentifier: userIdentifier,
                                                identityToken: identityToken,
                                                name: name
                                            )
                                            // Register for provisional push notifications on login
                                            AppState.shared.enablePushNotifications()
                                            isLoggingIn = false
                                        } catch {
                                            isLoggingIn = false
                                            errorMessage = error.localizedDescription
                                            showError = true
                                        }
                                    }
                                default:
                                    break
                                }
                            case .failure(let error):
                                if let authError = error as? ASAuthorizationError {
                                    switch authError.code {
                                    case .canceled:
                                        AppLogger.instance("Auth").info("User dismissed Login with Apple.")
                                    default:
                                        errorMessage = authError.localizedDescription
                                        showError = true
                                    }
                                } else {
                                    // It's a different error, show the error message
                                    errorMessage = error.localizedDescription
                                    showError = true
                                }
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .whiteOutline : .black)
                    .frame(height: 50)
                    .shadow(color: .gray, radius: 0.5)
                    .disabled(isLoggingIn)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .alert("Error", isPresented: $showError) {
                Button("Ok") {
                    showError = false
                    errorMessage = ""
                }
            } message: {
                Text(errorMessage)
            }

            if isLoggingIn {
                LoadingOverlayView()
            }
        }
    }

}

#Preview {
    LoginView()
}

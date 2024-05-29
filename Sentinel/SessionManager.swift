import Foundation
import Combine
import LocalAuthentication

struct IntercomHashResponse: Codable {
    var hash: String
}

class Session: ObservableObject {
    static let shared = Session()

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var serverSession: ServerSession?

    var isRefreshingToken = false
    private var refreshTask: Task<Bool, Never>?

    init() {
        self.currentUser = getCurrentUser()
        self.isLoggedIn = self.currentUser != nil
    }

    func getCurrentUser() -> User? {
        return retrieveUserFromStorage()
    }

    func getToken() async -> String? {
        return retrieveToken(forKey: SESSION_TOKEN_KEY)
    }

    func refreshSession() async -> Bool {
        if isRefreshingToken, let refreshTask = refreshTask {
            AppLogger.instance("Sessions").info("Already refreshing, waiting for its competion")
            return await refreshTask.value
        } else {
            AppLogger.instance("Sessions").info("Not yet refreshing, performing a refresh")
            isRefreshingToken = true
            // Start a new refresh task and store its reference.
            refreshTask = Task { () -> Bool in
                let success = await self.performTokenRefresh()
                // After completing the refresh, reset the state.
                DispatchQueue.main.async {
                    self.isRefreshingToken = false
                    self.refreshTask = nil
                }
                return success
            }
            // Wait for the new refresh task to complete.
            return await refreshTask!.value
        }
    }

    func performTokenRefresh() async -> Bool {
        guard let refreshToken = retrieveToken(forKey: REFRESH_TOKEN_KEY) else {
            await signOut()
            return false
        }

        var refreshSuccess = false
        do {
            AppLogger.instance("Sessions").info("Performing a refresh")
            let requestData: [String: Any] = ["refresh_token": refreshToken]
            let data = try await apiCall(urlPath: "/sessions/refresh", requestData: requestData, maxRetryCount: 0)

            if let decodedResponse = try? JSONDecoder().decode(ServerSession.self, from: data) {
                DispatchQueue.main.async {
                    self.serverSession = decodedResponse
                }
                storeTokenAndExpiration(
                    accessToken: decodedResponse.accessToken,
                    refreshToken: decodedResponse.refreshToken,
                    exp: decodedResponse.exp
                )
                refreshSuccess = true
            }
        } catch {
            refreshSuccess = false
        }

        return refreshSuccess
    }

    func createSessionFromAppleCredentials(userIdentifier: String, identityToken: String, name: String) async throws -> ServerSession? {
        let requestData: [String: Any] = [
            "user_identifier": userIdentifier,
            "identity_token": identityToken,
            "name": name
        ]

        let data = try await apiCall(urlPath: "/sessions/oauth/apple", requestData: requestData)
        if let decodedResponse = try? JSONDecoder().decode(ServerSession.self, from: data) {
            DispatchQueue.main.async {
                self.serverSession = decodedResponse
            }
            return decodedResponse
        } else {
            return nil
        }
    }

    func loginWithApple(userIdentifier: String, identityToken: Data?, name: String) async throws {
        guard let identityTokenData = identityToken,
              let identityTokenString = String(data: identityTokenData, encoding: .utf8)
        else {
            AppLogger.instance("SessionsManager").error("Could not login with Apple, missing information")
            throw NSError(domain: Bundle.main.bundleIdentifier!, code: 401, userInfo: [NSLocalizedDescriptionKey: "Could not authenticate request. Please try again."])
        }

        let session = try await createSessionFromAppleCredentials(
            userIdentifier: userIdentifier,
            identityToken: identityTokenString,
            name: name
        )
        if let session {
            /// Store session data for later quick retrieval
            storeUser(user: session.user, forKey: CURRENT_USER_KEY)
            storeTokenAndExpiration(accessToken: session.accessToken, refreshToken: session.refreshToken, exp: session.exp)
            await syncTimezone()
            DispatchQueue.main.async {
                self.currentUser = session.user
            }
        } else {
            AppLogger.instance("SessionsManager").error("Could not login with Apple, no session")
            let error = NSError(domain: Bundle.main.bundleIdentifier!, code: 401, userInfo: [NSLocalizedDescriptionKey: "Could not authenticate request. Please try again."])
            throw error
        }

        DispatchQueue.main.async {
            self.isLoggedIn = true
        }
    }

    func createSessionFromGoogleCredentials(
        idToken: String,
        name: String?,
        email: String?
    ) async throws -> ServerSession? {
        var requestData: [String: Any] = [
            "platform": "ios",
            "auth_data": [
                "id_token": idToken
            ]
        ]

        var profileData = [String: Any]()
        if let name {
            profileData["name"] = name
        }

        if email != nil {
            profileData["email_verified"] = true
        }

        if !profileData.isEmpty {
            requestData["profile_data"] = profileData
        }

        let data = try await apiCall(urlPath: "/sessions/oauth/google", requestData: requestData)
        guard let decodedResponse = try? JSONDecoder().decode(ServerSession.self, from: data) else {
            return nil
        }

        DispatchQueue.main.async {
            self.serverSession = decodedResponse
        }

        return decodedResponse
    }

    func signOut() async {
        do {
            _ = try await apiCall(urlPath: "/sessions/logout", requestData: nil, maxRetryCount: 0)
        } catch {
            AppLogger.instance("SessionsManager").error("Error logging out on server: \(error.localizedDescription, privacy: .public)")
        }
        UserDefaults.standard.set(false, forKey: INTERCOM_USER_LOGGED_IN_KEY)
        resetSession()
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.serverSession = nil
        }
    }

    func syncUser() async throws {
        let data = try await apiCall(urlPath: "/me", method: "GET", requestData: nil)
        if let user = try? JSONDecoder().decode(User.self, from: data) {
            DispatchQueue.main.async {
                self.storeUser(user: user, forKey: CURRENT_USER_KEY)
                self.currentUser = user
            }
        }
    }

    func syncTimezone() async {
        let requestData = [
            "user": [
                "timezone": TimeZone.current.identifier
            ]
        ]

        do {
            _ = try await apiCall(urlPath: "/me/update", requestData: requestData)
        } catch {
            AppLogger.instance("SessionsManager").error("Unable to sync timezone: \(error.localizedDescription, privacy: .public)")
        }
    }

    func getIntercomHash() async -> String? {
        do {
            let data = try await apiCall(urlPath: "/users/intercom/ios_hash", method: "GET", requestData: nil)
            if let decodedResponse = try? JSONDecoder().decode(IntercomHashResponse.self, from: data) {
                return decodedResponse.hash
            } else {
                return nil
            }
        } catch {
            AppLogger.instance("SessionsManager").error("Unable to get Intercom hash: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private func storeUser(user: User, forKey key: String) {
        do {
            let jsonData = try JSONEncoder().encode(user)
            setKeychainValue(jsonData, for: key)
        } catch {
            print("Error serializing JSON to Data: \(error)")
        }
    }

    private func storeToken(token: String, forKey key: String) {
        let data = Data(token.utf8)
        setKeychainValue(data, for: key)
    }

    private func storeTokenAndExpiration(accessToken: String, refreshToken: String?, exp: Int?) {
        let data = Data(accessToken.utf8)
        setKeychainValue(data, for: SESSION_TOKEN_KEY)

        if let refreshToken = refreshToken {
            let refreshTokenData = Data(refreshToken.utf8)
            setKeychainValue(refreshTokenData, for: REFRESH_TOKEN_KEY)
        }

        if let expiration = exp {
            let expirationString = String(expiration)
            let expirationData = Data(expirationString.utf8)
            setKeychainValue(expirationData, for: TOKEN_EXPIRATION_KEY)
        }
    }

    private func retrieveToken(forKey key: String) -> String? {
        if let data = getKeychainValue(for: key), let result = String(data: data, encoding: .utf8) {
            return result
        } else {
            return nil
        }
    }

    private func retrieveUserFromStorage() -> User? {
        guard let userData = getKeychainValue(for: CURRENT_USER_KEY) else { return nil }

        do {
            return try JSONDecoder().decode(User.self, from: userData)
        } catch {
            return nil
        }
    }

    private func resetSession() {
        deleteKeychainValue(for: SESSION_TOKEN_KEY)
        deleteKeychainValue(for: REFRESH_TOKEN_KEY)
        deleteKeychainValue(for: TOKEN_EXPIRATION_KEY)
        deleteKeychainValue(for: CURRENT_USER_KEY)
    }
}

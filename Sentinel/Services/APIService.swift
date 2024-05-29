import Foundation
import Combine

struct APIErrorResponse: Decodable {
    var error: String
    var message: String
}

func apiCall(
    urlPath: String,
    method: String = "POST",
    requestData: [String: Any]?,
    retryCount: Int = 0,
    maxRetryCount: Int = 3,
    requestTimeout: Double = 60
) async throws -> Data {
    let session = Session.shared

    var accessToken = await session.getToken()
    let url = URL(string: "\(API_BASE_URL)\(urlPath)")!
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.timeoutInterval = requestTimeout

    if let requestData = requestData {
        if let jsonData = try? JSONSerialization.data(withJSONObject: requestData) {
            request.httpBody = jsonData
        }
    }

    func setAuthorizationHeader(token: String?) {
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    setAuthorizationHeader(token: accessToken)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let (responseData, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.instance("Networking").error("Unknown server issues, not valid response: \(response, privacy: .public)")
            let error = NSError(domain: Bundle.main.bundleIdentifier!, code: 400, userInfo: [NSLocalizedDescriptionKey: "Unknown error."])
            throw error
        }

        if 400...599 ~= httpResponse.statusCode {
            if httpResponse.statusCode == 401 && urlPath == "/sessions/logout" {
                AppLogger.instance("Networking").error("Unable to log out on server: \(response, privacy: .public)")
                let error = NSError(domain: Bundle.main.bundleIdentifier!, code: 500, userInfo: [NSLocalizedDescriptionKey: "Unable to log out on server."])
                throw error
            } else if httpResponse.statusCode == 401 {
                if retryCount < maxRetryCount {
                    _ = await session.refreshSession()
                    accessToken = await session.getToken()
                    return try await apiCall(urlPath: urlPath, method: method, requestData: requestData, retryCount: retryCount + 1, maxRetryCount: maxRetryCount, requestTimeout: requestTimeout)
                } else {
                    await session.signOut()
                }
            } else {
                let decodedData = try JSONDecoder().decode(APIErrorResponse.self, from: responseData)
                let error = NSError(domain: Bundle.main.bundleIdentifier!, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: decodedData.message])
                throw error
            }
        }
        return responseData

    } catch let error as URLError where error.code == .networkConnectionLost && retryCount < maxRetryCount {
        // If network connection was lost and we haven't exceeded max retry count, retry after a delay
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
        return try await apiCall(urlPath: urlPath, method: method, requestData: requestData, retryCount: retryCount + 1, maxRetryCount: maxRetryCount, requestTimeout: requestTimeout)
    } catch let error as URLError where error.code == .timedOut && retryCount < maxRetryCount {
        // If request timed out and we haven't exceeded max retry count, retry after a delay
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return try await apiCall(urlPath: urlPath, method: method, requestData: requestData, retryCount: retryCount + 1, maxRetryCount: maxRetryCount, requestTimeout: requestTimeout)
    } catch let error as URLError where error.code == .cancelled {
        AppLogger.instance("Networking").error("Request cancelled - failing silently: \(error.localizedDescription, privacy: .public)")
        return Data()
    } catch let error {
        throw error
    }
}

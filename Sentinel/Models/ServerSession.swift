import Foundation

struct ServerSession: Codable {
    var accessToken: String
    var refreshToken: String?
    var exp: Int?
    var iat: Int?
    var user: User
}

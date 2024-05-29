import Foundation
import SwiftUI

struct AlertViewContent {
    var title: String
    var message: String
    var action: (() -> Void)?
}

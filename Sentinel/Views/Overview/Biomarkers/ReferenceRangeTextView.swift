import SwiftUI

struct ReferenceRangeTextView: View {
    let referenceRangeString: String?

    var body: some View {
        Text("Reference range: \(referenceRangeString != nil ? referenceRangeString! : "Not provided")")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

// #Preview {
//    ReferenceRangeTextView()
// }

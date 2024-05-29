import SwiftUI

struct BiomarkerHeaderView: View {
    var biomarker: Biomarker

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(biomarker.name)
                .font(.headline)
            if let description = biomarker.description {
                Text(description)
                    .font(.subheadline)
            }
        }
    }
}

// #Preview {
//    BiomarkerHeaderView()
// }

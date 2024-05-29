import SwiftUI

struct BiomarkerTextView: View {
    let samples: [LabResult]

    var uniqueSamples: [LabResult] {
        samples.reduce(into: []) { (result, sample) in
            guard let issuedDate = sample.issuedDate, let valueString = sample.valueString else { return }
            let identifier = "\(issuedDate.timeIntervalSince1970)-\(valueString)"

            if !result.contains(where: {
                guard let existingIssuedDate = $0.issuedDate, let existingValueString = $0.valueString else { return false }
                return "\(existingIssuedDate.timeIntervalSince1970)-\(existingValueString)" == identifier
            }) {
                result.append(sample)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(uniqueSamples) { sample in
                VStack(alignment: .leading) {
                    if let text = sample.valueString {
                        if let _ = sample.referenceRangeString {
                            HStack(alignment: .lastTextBaseline) {
                                Text(text)
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                if let issuedDate = sample.issuedDate {
                                    Text("on: \(dateString(issuedDate, style: .medium))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } else {
                            HStack(alignment: .firstTextBaseline) {
                                if let issuedDate = sample.issuedDate {
                                    Text("\(dateString(issuedDate, style: .medium)): ")
                                        .font(.headline)
                                }
                                Text(text)
                                    .opacity(0.9)
                            }
                        }
                    }

                    if let referenceRangeString = sample.referenceRangeString {
                        ReferenceRangeTextView(referenceRangeString: referenceRangeString)
                    }
                    if let source = sample.source {
                        Text("Source: \(source)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    func getTextPrefix(sample: LabResult) -> String {
        if let issuedDate = sample.issuedDate {
            return "\(dateString(issuedDate, style: .medium)): "
        }
        return ""
    }
}

// #Preview {
//    BiomarkerCommentsView()
// }

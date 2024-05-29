import SwiftUI

struct LabResultCellView: View {
    @Environment(\.colorScheme) var colorScheme

    let labResult: LabResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let biomarker = labResult.biomarker {
                BiomarkerHeaderView(biomarker: biomarker)
            } else {
                HStack {
                    Text(labResult.name)
                        .font(.headline)
                }
            }

            Divider()

            if labResult.value != nil {
                BiomarkerHorizontalChartView(labResult: labResult)
                    .id(labResult.id)
            } else if let value = labResult.valueString {
                Text(value)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
                    .blendMode(colorScheme == .light ? .plusDarker : .normal)

                if labResult.referenceRangeString != nil || labResult.source != nil {
                    VStack(alignment: .leading) {
                        if let referenceRangeString = labResult.referenceRangeString {
                            Text("Reference range: \(referenceRangeString)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if let source = labResult.source {
                            Text("Source: \(source)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 8)
        .listRowSeparator(.hidden)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 10)
                .background(.clear)
                .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                .padding(
                    EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 8,
                        trailing: 0
                    )
                )
        )
    }
}

 #Preview {
     List {
         LabResultCellView(labResult: LabResult(
            id: "123",
            name: "Comment",
            valueString: "This is a comment."
         ))
         LabResultCellView(labResult: LabResult(
            id: "123456",
            name: "Blood Glucose",
            issued: "2024-03-13 22:43:24 UTC",
            value: 45,
            valueUnit: "mg/dL",
            valueString: "95 mg/dL",
            referenceRangeString: "61 - 100 mg/dL",
            referenceRange: LabResultReferenceRange(
                low: 61.0,
                high: 100.0
            )
         ))
     }
 }

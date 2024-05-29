import SwiftUI
import Charts

struct LabTestOrderResultChartView: View {
    let labResult: LabResult
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.calendar) var calendar

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(labResult.formattedValue ?? "")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
            }
            .opacity(0.0)

            Chart {
                RuleMark(
                    x: .value("Date", labResult.issuedDate ?? Date())
                )
                .foregroundStyle(.gray.opacity(0.3))
                .offset(yStart: -10)
                .zIndex(-1)
                .annotation(
                    position: .top, spacing: 0,
                    overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .disabled
                    )
                ) {
                    valueSelectionPopover
                }
                if let referenceRange = labResult.referenceRange {
                    RuleMark(
                        xStart: nil, y: .value("Value", referenceRange.low ?? 0)
                    )
                    .lineStyle(.init(dash: [5, 5]))
                    .foregroundStyle(.blue)
                    if let high = referenceRange.high {
                        RuleMark(
                            xStart: nil, y: .value("Value", high)
                        )
                        .lineStyle(.init(dash: [5, 5]))
                        .foregroundStyle(.blue)
                    }
                    RectangleMark(
                        xStart: nil,
                        xEnd: nil,
                        yStart: .value("Value", referenceRange.low ?? 0),
                        yEnd: .value("Value", referenceRange.high ?? .infinity)
                    )
                    .foregroundStyle(.blue)
                    .opacity(0.1)

                }

                if let issuedDate = labResult.issuedDate, let value = labResult.value {
                    LineMark(
                        x: .value("Date", issuedDate),
                        y: .value("Value", value)
                    )
                    .foregroundStyle(colorScheme == .dark ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5))
                    .lineStyle(StrokeStyle(lineWidth: 1))

                    if let referenceRange = labResult.referenceRange {
                        PointMark(x: .value("Date", issuedDate), y: .value("Value", value))
                            .symbolSize(100)
                            .foregroundStyle(value > referenceRange.high ?? .infinity || value < referenceRange.low ?? 0 ? .red : .green)
                    } else {
                        PointMark(x: .value("Date", issuedDate), y: .value("Value", value))
                            .symbolSize(100)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .trailing) { _ in
                    AxisValueLabel()
                }
            }
            .frame(height: 75)
        }
    }

    @ViewBuilder
    var valueSelectionPopover: some View {
        if let formattedValue = labResult.formattedValue {
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(formattedValue)
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.semibold)

                            Text(labResult.valueUnit ?? "")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

            }
            .padding(4)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    LabTestOrderResultChartView(labResult: LabResult(
        id: "123456",
        name: "Blood Glucose",
        issued: "2024-03-13 22:43:24 UTC",
        value: 115.0,
        valueUnit: "mg/dL",
        valueString: "115 mg/dL",
        referenceRangeString: "61 - 100 mg/dL",
        referenceRange: LabResultReferenceRange(
            low: 61.0,
            high: 100.0
        )
    ))
    .padding()
}

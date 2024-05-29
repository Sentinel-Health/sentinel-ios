import SwiftUI
import Charts

struct BiomarkerHorizontalChartView: View {
    let labResult: LabResult
    var showDate: Bool = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.calendar) var calendar

    @State private var isShowingReferenceRangePopover = false

    // This view is a bit of a mess right now but it works, TODO: refactor this
    var body: some View {
        VStack(alignment: .leading) {
            if let formattedValue = labResult.formattedValue {
                VStack(alignment: .leading) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(formattedValue)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.semibold)

                        Text(labResult.valueUnit ?? "")
                            .foregroundStyle(.secondary)

                        if showDate, let date = labResult.issuedDate {
                            Text("on: \(dateString(date, style: .medium))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if labResult.outOfReferenceRange {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.orange)
                                .padding(.horizontal, 4)
                                .onTapGesture {
                                    isShowingReferenceRangePopover.toggle()
                                }
                                .popover(isPresented: $isShowingReferenceRangePopover) {
                                    VStack {
                                        Text("This result is outside the reference range.")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .padding()
                                    }
                                    .presentationCompactAdaptation(.none)
                                }
                        }
                    }
                }
                .padding(4)
            }

            if let referenceRange = labResult.referenceRange, let value = labResult.value {
                GeometryReader { geometry in
                    HStack(spacing: 4) {
                        let lowRangeWidth = geometry.size.width * (referenceRange.low ?? 0 > 0 ? referenceRange.high != nil ? 0.25 : 0.3 : 0.7)
                        let highRangeWidth = geometry.size.width * (referenceRange.high != nil ? referenceRange.low ?? 0 > 0 ? 0.25 : 0.3 : 0.7)
                        let middleRangeWidth = geometry.size.width * 0.5
                        let isLow = referenceRange.low ?? 0 > 0 && value < referenceRange.low ?? 0
                        let isHigh = referenceRange.high != nil && value > referenceRange.high ?? .infinity
                        let isLowNormal = referenceRange.low ?? 0 == 0 && referenceRange.high != nil
                        let isHighNormal = referenceRange.high == nil && referenceRange.low ?? 0 > 0

                        ZStack {
                            Rectangle()
                                .fill(isLow ? LinearGradient(colors: [.red, .yellow], startPoint: .leading, endPoint: .trailing) :
                                        isLowNormal ? LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [.red, .yellow], startPoint: .leading, endPoint: .trailing) )
                                .opacity(colorScheme == .dark ? 1.0 : 0.8)
                                .frame(width: lowRangeWidth, height: 10)
                                .cornerRadius(5)

                            if isLow {
                                let low = CGFloat(0)
                                let high = CGFloat(referenceRange.low ?? 0)
                                let valueCG = CGFloat(value)
                                let totalRange = high - low
                                let normalizedValue = totalRange > 0 ? (valueCG - low) / totalRange : 0

                                let dotPosition = normalizedValue * lowRangeWidth
                                let dotXPosition = min(max(dotPosition, 0), lowRangeWidth)

                                Circle()
                                    .fill(colorScheme == .dark ? .white : .black)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle().stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                                    )
                                    .position(x: dotXPosition, y: geometry.size.height / 2)
                            } else if isLowNormal && value <= referenceRange.high ?? .infinity {
                                let low = CGFloat(0)
                                let high = CGFloat(referenceRange.high ?? .infinity)
                                let valueCG = CGFloat(value)
                                let totalRange = high - low
                                let normalizedValue = totalRange > 0 ? (valueCG - low) / totalRange : 0

                                let dotPosition = normalizedValue * lowRangeWidth
                                let dotXPosition = min(max(dotPosition, 0), lowRangeWidth)

                                Circle()
                                    .fill(colorScheme == .dark ? .white : .black)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle().stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                                    )
                                    .position(x: dotXPosition, y: geometry.size.height / 2)
                            }
                        }

                        if referenceRange.low ?? 0 > 0 && referenceRange.high != nil {
                            let low = CGFloat(referenceRange.low ?? 0)
                            let high = CGFloat(referenceRange.high ?? .infinity)
                            let valueCG = CGFloat(value)
                            let totalRange = high - low
                            let normalizedValue = totalRange > 0 ? (valueCG - low) / totalRange : 0

                            ZStack {
                                Rectangle()
                                    .fill(LinearGradient(colors: [.blue, .green, .blue], startPoint: .leading, endPoint: .trailing))
                                    .opacity(colorScheme == .dark ? 1.0 : 0.8)
                                    .frame(width: middleRangeWidth, height: 10)
                                    .cornerRadius(5)

                                if value >= referenceRange.low ?? 0 && value <= referenceRange.high ?? .infinity {
                                    let dotPosition = normalizedValue * middleRangeWidth
                                    let dotXPosition = min(max(dotPosition, 0), middleRangeWidth)

                                    Circle()
                                        .fill(colorScheme == .dark ? .white : .black)
                                        .frame(width: 10, height: 10)
                                        .overlay(
                                            Circle().stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                                        )
                                        .position(x: dotXPosition, y: geometry.size.height / 2)
                                }
                            }
                        }

                        ZStack {
                            Rectangle()
                                .fill(isHigh ? LinearGradient(colors: [.yellow, .red], startPoint: .leading, endPoint: .trailing) :
                                        isHighNormal ? LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [.yellow, .red], startPoint: .leading, endPoint: .trailing))
                                .opacity(colorScheme == .dark ? 1.0 : 0.8)
                                .frame(width: highRangeWidth, height: 10)
                                .cornerRadius(5)

                            if let highValue = referenceRange.high, isHigh {
                                let low = CGFloat(highValue)
                                let high = CGFloat(highValue + highValue * 2)
                                let valueCG = CGFloat(value)
                                let totalRange = high - low
                                let normalizedValue = totalRange > 0 ? (valueCG - low) / totalRange : 0

                                let dotPosition = normalizedValue * highRangeWidth
                                let dotXPosition = min(max(dotPosition, 0), highRangeWidth)

                                Circle()
                                    .fill(colorScheme == .dark ? .white : .black)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle().stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                                    )
                                    .position(x: dotXPosition, y: geometry.size.height / 2)
                            } else if isHighNormal && value >= referenceRange.low ?? 0, let lowValue = referenceRange.low {
                                let low = CGFloat(lowValue)
                                let high = CGFloat(lowValue + lowValue * 1.5)
                                let valueCG = CGFloat(value)
                                let totalRange = high - low
                                let normalizedValue = totalRange > 0 ? (valueCG - low) / totalRange : 0

                                let dotPosition = normalizedValue * highRangeWidth
                                let dotXPosition = min(max(dotPosition, 0), highRangeWidth)

                                Circle()
                                    .fill(colorScheme == .dark ? .white : .black)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle().stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                                    )
                                    .position(x: dotXPosition, y: geometry.size.height / 2)
                            }
                        }
                    }
                }
                .frame(height: 10)

                ReferenceRangeTextView(referenceRangeString: labResult.referenceRangeString)
            }

            if let source = labResult.source {
                Text("Source: \(source)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    BiomarkerHorizontalChartView(labResult: LabResult(
        id: "123456",
        name: "Blood Glucose",
        issued: "2024-03-13 22:43:24 UTC",
        value: 115.0,
        valueUnit: "mg/dL",
        valueString: "115 mg/dL",
        referenceRangeString: "61 - 100mg/dL",
        referenceRange: LabResultReferenceRange(
            low: 61.0,
            high: 100.0
        )
    ))
    .padding()
}

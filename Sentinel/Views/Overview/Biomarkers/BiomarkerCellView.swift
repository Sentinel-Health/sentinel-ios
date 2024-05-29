import SwiftUI

struct BiomarkerCellView: View {
    let biomarker: Biomarker

    @State private var rawSelectedDate: Date?
    @State private var lastSelectedDate: Date?
    @State private var showAllSamples = false

    private var hasMoreSamplesThanShownInitially: Bool {
        guard let mostRecentDate = biomarker.filteredAndSortedSamples.first?.issuedDate else {
            return false
        }
        let mostRecentSampleCount = biomarker.filteredAndSortedSamples.filter { $0.issuedDate == mostRecentDate }.count
        return biomarker.filteredAndSortedSamples.count > mostRecentSampleCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            BiomarkerHeaderView(biomarker: biomarker)
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                ForEach(filteredSamples) { sample in
                    Group {
                        if let _ = sample.value {
                            BiomarkerHorizontalChartView(labResult: sample, showDate: true)
                        } else {
                            BiomarkerTextView(samples: [sample])
                        }
                    }
                }
            }

            if hasMoreSamplesThanShownInitially {
                Button(action: {
                    showAllSamples.toggle()
                }) {
                    HStack {
                        Text(showAllSamples ? "Hide Older Results" : "Show All Results")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: showAllSamples ? "chevron.up" : "chevron.down")
                    }
                }
                .padding(.top, 10)
            }
        }
        .onChange(of: rawSelectedDate, {
            if let rawDate = rawSelectedDate {
                lastSelectedDate = rawDate
            }
        })
    }

    private var filteredSamples: [LabResult] {
        let allSamples = biomarker.filteredAndSortedSamples
        if showAllSamples {
            return allSamples
        } else {
            guard let mostRecentDate = allSamples.first?.issuedDate else {
                return []
            }
            return allSamples.filter { $0.issuedDate == mostRecentDate }
        }
    }
}

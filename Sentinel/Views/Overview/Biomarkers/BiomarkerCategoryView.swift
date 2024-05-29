import SwiftUI

struct BiomarkerCategoryView: View {
    @Environment(\.colorScheme) var colorScheme

    let category: BiomarkerCategory

    var body: some View {
        VStack {
            List {
                ForEach(category.subcategories) { subcategory in
                    Section(
                        header: BiomarkerSubcategoryHeaderView(subcategory: subcategory)
                            .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                    ) {
                        ForEach(subcategory.biomarkers) { biomarker in
                            VStack(alignment: .leading, spacing: 8) {
                                BiomarkerCellView(biomarker: biomarker)
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
                    .headerProminence(.increased)
                }
            }
            .listSectionSpacing(.compact)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("\(category.name)")
    }
}

struct BiomarkerSubcategoryHeaderView: View {
    var subcategory: BiomarkerSubcategory

    var body: some View {
        VStack(alignment: .leading) {
            Text(subcategory.name)
        }
    }
}

// #Preview {
//    BiomarkerCategoryView()
// }

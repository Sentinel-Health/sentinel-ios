import SwiftUI

struct CheckboxView: View {
    @Binding var checked: Bool

    var label: String?
    var isDisabled: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)

            if let label = label {
                Text(.init(label))
            }
        }
        .onTapGesture {
            if !isDisabled {
                self.checked.toggle()
            }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

struct CheckboxView_Previews: PreviewProvider {
    struct CheckboxViewHolder: View {
        @State var checked = false

        var body: some View {
            CheckboxView(checked: $checked, label: "Hello, checkbox")
        }
    }

    static var previews: some View {
        CheckboxViewHolder()
    }
}

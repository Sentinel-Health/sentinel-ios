import SwiftUI

struct ChatFunctionCallView: View {
    var message: Message
    var isLoading: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "checkmark").foregroundColor(.green)
                }
                Text(getFunctionMessageForName(message: message, isLoading: isLoading))
            }.padding(.vertical, 0).frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.horizontal)
    }
}

func getFunctionMessageForName(message: Message, isLoading: Bool) -> String {
    let functionName = message.functionCall?.name ?? message.name ?? ""

    switch functionName {
    case "healthQuantitySamplesQuery", "healthCategorySamplesQuery":
        return isLoading
          ? "Looking through the data..."
          : "Finished looking through the data."
    default:
        return isLoading ? "Loading..." : "Finished."
    }
}

#Preview {
    ChatFunctionCallView(message: Message(
        role: "assistant",
        content: nil,
        functionCall: FunctionCall(
            name: "healthCategorySamplesQuery",
            arguments: ""
        )
    ), isLoading: false)
}

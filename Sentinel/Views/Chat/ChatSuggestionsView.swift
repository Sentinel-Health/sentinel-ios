import SwiftUI

struct ChatSuggestionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: ChatViewModel

    let suggestions: [ChatSuggestion]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Try a suggestion")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(suggestions) { suggestion in
                        Button(action: {
                            viewModel.startConversationWithPrompt(chatPrompt: suggestion.prompt)
                            viewModel.markChatSuggestionUsed(suggestion.id)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 15, weight: .bold))

                                    Text(suggestion.description)
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 15))
                                }
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .opacity(0.5)
                            }
                        }
                        .frame(width: 300, height: 80)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .tint(colorScheme == .dark ? .white : .black)
                        .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(colorScheme == .dark ? Color(UIColor.systemGray4) : Color(UIColor.systemGray5), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// #Preview {
//    BiomarkersSummaryView()
// }

import SwiftUI

struct ConversationCellView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatViewModel: ChatViewModel

    let conversation: Conversation
    let onTap: () -> Void
    let onError: (_ error: Error) -> Void

    var body: some View {
        Button(action: {
            Task {
                do {
                    try await chatViewModel.selectConversation(conversationId: conversation.id)
                    onTap()
                } catch {
                    onError(error)
                }
            }
        }, label: {
            HStack {
                VStack {
                    if let title = conversation.title {
                        Text(title)
                            .font(.headline)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(conversation.messages.last?.content ?? "")
                            .font(.headline)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text("Last message: \(dateString(isoStringToDate(conversation.lastActivityAt ?? "") ?? Date(), style: .medium))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                NavigationLinkIconView()
            }
        })
        .frame(alignment: .leading)
        .foregroundColor(colorScheme == .dark ? .white : .black)
    }
}

// #Preview {
//    ConversationCellView()
// }

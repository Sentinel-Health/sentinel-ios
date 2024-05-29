import SwiftUI
import MarkdownUI
import AlertToast

struct ChatMessageView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    var message: Message
    var isLoading: Bool = false

    @State var showSelectTextView: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if message.role == "user" {
                    Image(systemName: "person.fill")
                    Text("You").font(.headline)
                } else {
                    Image(systemName: "shield.fill")
                    Text("Sentinel").font(.headline)
                }
            }.padding(.horizontal)
            if isLoading {
                HStack(spacing: 6) {
                    Text("Sentinel is responding...")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                if let content = message.content {
                    Markdown(content)
                        .markdownTextStyle(\.link) {
                            ForegroundColor(.blue)
                            UnderlineStyle(.single)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contextMenu {
                            Button(action: { copyText() }) {
                                Text("Copy")
                                Image(systemName: "doc.on.doc")
                            }
                            Button(action: { selectText() }) {
                                Text("Select")
                                Image(systemName: "selection.pin.in.out")
                            }
                            if message.role == "assistant" {
                                Button(action: { submitFeedback(true) }) {
                                    Text("Helpful")
                                    Image(systemName: "hand.thumbsup")
                                }
                                Button(action: { submitFeedback(false) }) {
                                    Text("Not Helpful")
                                    Image(systemName: "hand.thumbsdown")
                                }
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $showSelectTextView) {
            if let content = message.content {
                SelectableTextSheetView(text: content, showingModal: $showSelectTextView)
            } else {
                // Dismiss view if no content
                EmptyView()
                    .onAppear {
                        showSelectTextView = false
                    }
            }
        }
    }

    func copyText() {
        UIPasteboard.general.string = message.content
        AppLogger.instance("UI").info("Text copied to clipboard")
    }

    func selectText() {
        showSelectTextView.toggle()
    }

    func submitFeedback(_ isHelpful: Bool) {
        if isHelpful {
            AppLogger.instance("UI").info("Feedback: helpful")
        } else {
            AppLogger.instance("UI").info("Feedback: not helpful")
        }

        Task {
            do {
                _ = try await apiCall(urlPath: "/chat/feedback", requestData: [
                    "message_id": message.id!,
                    "feedback_type": isHelpful ? "positive" : "negative"
                ])
            } catch {
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.showFeedbackToast = true
        }
    }
}

struct SelectableTextSheetView: View {
    var text: String

    @Binding var showingModal: Bool

    var body: some View {
        NavigationStack {
            VStack {
                SelectableTextView(text: text)
            }
            .navigationTitle("Select Text")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                    showingModal = false
                }
            ) {
                Image(systemName: "multiply")
            }
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.secondary)
            )
        }
    }
}

struct SelectableTextView: UIViewRepresentable {
    var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.isSelectable = true
        textView.isEditable = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)

        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            uiView.selectAll(nil)
        }
    }
}

#Preview {
    ChatMessageView(message: Message(
        role: "assistant",
        content: "Hello, world! This is some *markdown* text just to see how it get's parsed.\n\n# Title\nParagraph with bullets:\n1. **hello**\n2. goodbye\n3. `code`"
    ))
}

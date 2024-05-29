import SwiftUI
import PhotosUI

struct PreviewItem: Identifiable {
    let id = UUID()
    let view: AnyView
    let url: String
}

struct MessageBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var newMessageText: String = ""
    @State private var showingPhotosPicker: Bool = false
    @State private var showingFilesPicker: Bool = false

    @State var selectedItems: [PhotosPickerItem] = []
    @State private var attachmentPreviews: [PreviewItem] = []

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
//                Menu {
//                    Button {
//                        showingFilesPicker.toggle()
//                    } label: {
//                        HStack {
//                            Text("Chose a file")
//                            Image(systemName: "folder")
//                        }
//                    }
//
//                    Button {
//                        showingPhotosPicker.toggle()
//                    } label: {
//                        HStack {
//                            Text("Choose a photo")
//                            Image(systemName: "photo.on.rectangle.angled")
//                        }
//                    }
//                } label: {
//                    Image(systemName: "plus.circle.fill")
//                        .font(.system(size: 32))
//                        .symbolRenderingMode(.hierarchical)
//                        .foregroundColor(.secondary)
//                        .padding(.vertical, 3)
//                }
//                .simultaneousGesture(
//                    TapGesture().onEnded {
//                        if viewModel.viewPresentationHeight == MINIMIZED_CHAT_VIEW_HEIGHT {
//                            viewModel.viewPresentationHeight = .large
//                        }
//                    }
//                )

                VStack(spacing: 0) {
                    if attachmentPreviews.count > 0 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(attachmentPreviews) { previewItem in
                                    previewItem.view
                                        .frame(maxWidth: 275)
                                }
                            }
                        }
                        .animation(.default, value: attachmentPreviews.isEmpty)
                        .padding(5)

                        Divider()
                    }

                    HStack(alignment: .bottom) {
                        TextField("Send message", text: $newMessageText, axis: .vertical)
                            .lineLimit(8)
                            .padding(.leading, 10)
                            .padding(.trailing, 4)
                            .padding(.vertical, 10)
                            .frame(minHeight: 42)

                        if viewModel.isAssistantResponding {
                            ProgressView()
                                .frame(width: 28, height: 28)
                                .padding(.horizontal, 2)
                                .padding(.vertical, 7)
                                .onAppear {
                                    newMessageText = ""
                                }
                        } else {
                            Button {
                                if !newMessageText.isEmpty {
                                    let newMessage = viewModel.addNewLocalMessage(message: newMessageText)
                                    Task {
                                        do {
                                            try await viewModel.sendMessageToServer(message: newMessage)
                                        } catch {
                                            viewModel.errorMessage = "Something went wrong trying to get a response to your message. Please try again or contact support if the problem persists."
                                            viewModel.showError = true
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
                            }
                            .padding(.vertical, 5)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .disabled(newMessageText.isEmpty)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 0)
                    .cornerRadius(20)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5), lineWidth: 1)
                )
            }

            Text("Sentinel messages are informational only and not medical advice. Always consult with a medical professional.")
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $selectedItems,
            matching: .any(of: [.images, .screenshots, .livePhotos])
        )
        .fileImporter(
            isPresented: $showingFilesPicker,
            allowedContentTypes: [.pdf, .json, .png, .jpeg, .heic, .html, .delimitedText, .emailMessage, .tabSeparatedText, .commaSeparatedText, .image],
            onCompletion: { result in
                handleFileSelection(result: result)
            }
        )
    }

    private func handlePhotoSelection() {
        for item in selectedItems {
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let data = data, let image = UIImage(data: data) {
                            // Create a view for the image preview
                            let imageView = Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(20)
                            let previewItem = PreviewItem(view: AnyView(imageView), url: "preview")
                            attachmentPreviews.append(previewItem)
                        }
                    case .failure(let error):
                        AppLogger.instance("UI").error("Failed to load image: \(error.localizedDescription, privacy: .public)")
                    }
                }
            }
        }
    }

    private func handleFileSelection(result: Result<URL, Error>) {
        // Here you might generate a preview for the selected file
        switch result {
            case .success(let url):
                // Create a view for the file preview
                let fileName = url.lastPathComponent
                let fileType = url.pathExtension
                let fileView = FileAttachmentPreviewView(fileName: fileName, fileType: fileType) {
                    self.removeAttachment(for: url)
                }
                let previewItem = PreviewItem(view: AnyView(fileView), url: url.absoluteString)
                attachmentPreviews.append(previewItem)
            case .failure(let error):
                // Handle any errors
                AppLogger.instance("UI").error("Failed to handle file: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func removeAttachment(for url: URL) {
        attachmentPreviews.removeAll { $0.url == url.absoluteString }
    }
}

// #Preview {
//    MessageBarView()
// }

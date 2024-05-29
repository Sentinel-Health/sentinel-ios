import SwiftUI

struct FileAttachmentPreviewView: View {
    @Environment(\.colorScheme) var colorScheme

    var fileName: String
    var fileType: String
    var onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 16) {
                Image(systemName: "doc.text")
                    .font(.system(size: 30))
                VStack(alignment: .leading, spacing: 5) {
                    Text(fileName)
                        .font(.headline)
                    Text(fileType)
                        .font(.subheadline)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)

            Button(action: onRemove) {
                Image(systemName: "multiply.circle.fill")
                    .font(.system(size: 20))
                    .background(Circle().fill(colorScheme == .dark ? .black : .white))
                    .foregroundColor(.secondary)
                    .padding([.top, .trailing], 10)
            }
            .contentShape(Circle())
        }
    }
}

#Preview {
    FileAttachmentPreviewView(fileName: "Hello world.pdf", fileType: "pdf", onRemove: {
        AppLogger.instance("UI").debug("remove me!")
    })
}

import SwiftUI

struct EmptyChatView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var viewModel: ChatViewModel

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            VStack(spacing: 8) {
                Image("icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                Text("Ask Sentinel")
                    .font(.title2)
                    .bold()
                if let user = Session.shared.currentUser {
                    if let firstName = user.firstName {
                        Text("\(timeOfDayGreeting()) \(firstName), how can I help you?")
                    } else {
                        Text("\(timeOfDayGreeting()), how can I help you?")
                    }
                }
            }
            .padding()

            Spacer()

            if viewModel.chatSuggestions.count > 0 {
                ChatSuggestionsView(suggestions: viewModel.chatSuggestions)
                    .environmentObject(viewModel)
            }
        }
    }

    func timeOfDayGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 1..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<25: return "Good evening"
        default: return "Hello"
        }
    }
}

#Preview {
    EmptyChatView()
        .padding()
}

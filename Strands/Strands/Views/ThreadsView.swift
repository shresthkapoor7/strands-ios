import SwiftUI

struct ThreadsView: View {
    @State private var isCreatingNewChat = false

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ChatView(chatId: "chat1", chatTitle: "Chat #1")) {
                    Text("Chat #1")
                }
                NavigationLink(destination: ChatView(chatId: "chat2", chatTitle: "Chat #2")) {
                    Text("Chat #2")
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isCreatingNewChat = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .background(
                NavigationLink(destination: ChatView(chatId: UUID().uuidString, chatTitle: "Untitled Chat"), isActive: $isCreatingNewChat) {
                    EmptyView()
                }
            )
        }
    }
}

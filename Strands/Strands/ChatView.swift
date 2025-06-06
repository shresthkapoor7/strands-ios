import SwiftUI

struct ChatView: View {
    let chatId: String
    @State var chatTitle: String

    @State private var input: String = ""
    @State private var context: [ChatMessage] = []
    @State private var isLoading: Bool = false

    @State private var selectedThreadRoot: ChatMessage? = nil
    @State private var navigateToThread = false

    let maxContextSize = 10

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(context) { msg in
                        HStack {
                            if msg.isUser { Spacer() }

                            VStack(alignment: msg.isUser ? .trailing : .leading) {
                                Text(msg.text)
                                    .padding()
                                    .background(msg.isUser ? Color.blue : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .frame(maxWidth: 250, alignment: msg.isUser ? .trailing : .leading)

                                if !msg.isUser {
                                    Button(action: {
                                        selectedThreadRoot = msg
                                        navigateToThread = true
                                    }) {
                                        Text("💬 Thread")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }

                            if !msg.isUser { Spacer() }
                        }
                        .padding(.horizontal)
                    }

                    if isLoading {
                        ProgressView().padding()
                    }
                }
            }

            Divider()

            HStack {
                TextField("Type something...", text: $input)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Send") {
                    send()
                }
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle(chatTitle)
        .navigationBarTitleDisplayMode(.inline)

        // 👇 NavigationLink that opens ThreadView
        NavigationLink(
            destination: Group {
                if let root = selectedThreadRoot {
                    ThreadView(rootMessage: root)
                } else {
                    // Add fallback view to satisfy SwiftUI's type system
                    Text("Loading...") // or EmptyView()
                }
            },
            isActive: $navigateToThread
        ) {
            EmptyView()
        }
        .hidden()
    }

    func enqueueMessage(_ msg: ChatMessage) {
        context.append(msg)
        if context.count > maxContextSize {
            context.removeFirst()
        }
    }

    func send() {
        let userMessage = ChatMessage(id: UUID().uuidString, text: input, isUser: true)
        enqueueMessage(userMessage)
        input = ""
        isLoading = true

        StrandsAPI.sendToGemini(context: context) { response in
            DispatchQueue.main.async {
                isLoading = false
                if let reply = response {
                    let botReply = ChatMessage(id: UUID().uuidString, text: reply, isUser: false)
                    enqueueMessage(botReply)

                    let userCount = context.filter { $0.isUser }.count
                    let modelCount = context.filter { !$0.isUser }.count
                    if userCount == 1 && modelCount == 1 {
                        requestChatTitle()
                    }
                }
            }
        }
    }

    func requestChatTitle() {
        let namingPrompt = ChatMessage(
            id: UUID().uuidString,
            text: "Based on this conversation, generate a short, descriptive title (max 5 words). Only respond with the title.",
            isUser: true
        )

        let titleContext = context + [namingPrompt]

        StrandsAPI.sendToGemini(context: titleContext) { titleResponse in
            if let newTitle = titleResponse?.trimmingCharacters(in: .whitespacesAndNewlines), !newTitle.isEmpty {
                DispatchQueue.main.async {
                    self.chatTitle = newTitle
                }
            }
        }
    }
}

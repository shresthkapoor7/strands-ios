import SwiftUI

struct ThreadView: View {
    let rootMessage: ChatMessage

    @State private var threadInput: String = ""
    @State private var threadContext: [ChatMessage] = []
    @State private var isLoading: Bool = false

    let maxThreadContextSize = 5

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Original Message").font(.headline)) {
                    HStack {
                        Text(rootMessage.text)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                ForEach(threadContext) { msg in
                    HStack {
                        if msg.isUser { Spacer() }
                        Text(msg.text)
                            .padding()
                            .background(msg.isUser ? Color.blue : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .frame(maxWidth: 250, alignment: msg.isUser ? .trailing : .leading)
                        if !msg.isUser { Spacer() }
                    }
                    .listRowBackground(Color.clear)
                }

                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)

            Divider()

            HStack {
                TextField("Reply in thread...", text: $threadInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)

                Button("Send") {
                    sendInThread()
                }
                .disabled(threadInput.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
        }
        .navigationTitle("Thread 🧵")
        .navigationBarTitleDisplayMode(.inline)
    }

    func enqueueThreadMessage(_ msg: ChatMessage) {
        threadContext.append(msg)
        if threadContext.count > maxThreadContextSize {
            threadContext.removeFirst()
        }
    }

    func sendInThread() {
        let userMessage = ChatMessage(id: UUID().uuidString, text: threadInput, isUser: true)
        enqueueThreadMessage(userMessage)
        threadInput = ""
        isLoading = true

        // Include rootMessage + just user/appended thread replies
        let fullContext = [rootMessage] + threadContext

        StrandsAPI.sendToGemini(context: fullContext) { response in
            DispatchQueue.main.async {
                isLoading = false
                if let reply = response {
                    let botReply = ChatMessage(id: UUID().uuidString, text: reply, isUser: false)
                    enqueueThreadMessage(botReply)
                }
            }
        }
    }
}

import Foundation

struct StrandsAPI {
    static func sendToGemini(context: [ChatMessage], completion: @escaping (String?) -> Void) {
        let contextPayload = context.map {
            ["role": $0.isUser ? "user" : "model", "parts": [["text": $0.text]]]
        }

        let body: [String: Any] = ["messages": contextPayload]

        guard let url = URL(string: "https://api.strandschat.com/api/gemini") else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let finalBody = ["contents": contextPayload]
            let jsonData = try JSONSerialization.data(withJSONObject: finalBody, options: .prettyPrinted)
            req.httpBody = jsonData

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Final JSON Body:\n\(jsonString)")
            }
        } catch {
            print("❌ Failed to encode request body:", error)
            completion(nil)
            return
        }

        print("📤 Sending context to Gemini API...")
        URLSession.shared.dataTask(with: req) { data, response, error in
            if let error = error {
                print("❌ Network error:", error)
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response object")
                completion(nil)
                return
            }

            print("📬 Response status: \(httpResponse.statusCode)")

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📦 Response JSON: \(json)")

                    if let candidates = json["candidates"] as? [[String: Any]],
                       let parts = candidates.first?["content"] as? [String: Any],
                       let text = (parts["parts"] as? [[String: Any]])?.first?["text"] as? String {
                        completion(text)
                        return
                    }
                }

                print("⚠️ Unexpected response format")
                completion(nil)
            } catch {
                print("❌ JSON parse error:", error)
                completion(nil)
            }
        }.resume()
    }
}

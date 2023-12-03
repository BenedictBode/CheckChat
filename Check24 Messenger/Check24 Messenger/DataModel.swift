//
//  DataModel.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 30.11.23.
//

import Foundation
import Combine

let baseURL = URL(string: "https://hidden-bayou-91236-aef7370094a2.herokuapp.com")!
//let baseURL = URL(string: "http://localhost:3000")!

class DataModel: ObservableObject {
    
    static let shared = DataModel()
    
    private var decoder: JSONDecoder = JSONDecoder()
    private var encoder: JSONEncoder = JSONEncoder()
    
    @Published var messages: [Message] = []
    @Published var conversations: [Conversation] = []
    @Published var viewType: SenderType = .customer
    
    private var cancellable: AnyCancellable?
    @Published private var timer: Timer.TimerPublisher = Timer.publish(every: 1.5, on: .main, in: .common)
    
    static func downloadURL(conversationId: Int, messageId: Int, fileName: String) -> URL {
        baseURL.appendingPathComponent("download")
            .appendingPathComponent(String(conversationId))
            .appendingPathComponent(String(messageId))
            .appendingPathComponent(fileName)
    }
    
    init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        cancellable = timer.autoconnect().sink { _ in
            Task {
                let conversations = (try? await self.fetchConversations()) ?? []
                let messages = (try? await self.fetchMessages()) ?? []
                await MainActor.run {
                    self.conversations = conversations
                    self.messages = messages
                }
            }
        }
    }
    
    func updateMessage(message: Message) {
        Task {
            let url = baseURL.appendingPathComponent("messages")
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let data = try encoder.encode(message)
            try? await URLSession.shared.upload(for: request, from: data)
        }
    }
    
    func updateConversation(conversation: Conversation) {
        Task {
            let url = baseURL.appendingPathComponent("conversations")
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let data = try encoder.encode(conversation)
            try? await URLSession.shared.upload(for: request, from: data)
        }
    }
    
    var otherViewType: SenderType {
        viewType == .customer ? .service_provider : .customer
    }
    
    func conversationName(conversation: Conversation) -> String {
        viewType == .customer ? conversation.service_provider_name : conversation.customer_name
    }
    
    
    func uploadFile(fileURL: URL, conversation_id: Int, message_id: Int) {
        do {
            let boundary = "Boundary-\(UUID().uuidString)"
            var request = URLRequest(url: baseURL.appendingPathComponent("upload")
                                        .appendingPathComponent(String(conversation_id))
                                        .appendingPathComponent(String(message_id)))
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            let fileData = try Data(contentsOf: fileURL)
            let filename = fileURL.lastPathComponent
            let mimeType = mimeTypeForPath(path: fileURL.path)

            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            URLSession.shared.uploadTask(with: request, from: body) { responseData, response, error in
                if let error = error {
                    print("Error uploading file: \(error)")
                    return
                }

                if let responseData = responseData {
                    print("Server Response: \(String(data: responseData, encoding: .utf8) ?? "")")
                }
            }.resume()
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    func reset() {
        Task {
            let (data, _) = try await URLSession.shared.data(from: baseURL.appendingPathComponent("reset"))
        }
    }

    func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension

        switch pathExtension {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        // Add more cases for other file types
        default:
            return "application/octet-stream"
        }
    }

    
    static func isImage(fileName path: String) -> Bool {
        let ext = (path as NSString).pathExtension.lowercased()

        switch ext {
        case "jpg", "jpeg":
            return true
        case "png":
            return true
        case "pdf":
            return false
        default:
            return false
        }
    }
    
    func uploadMessage(message: Message) throws {
        Task {
            let url = baseURL.appendingPathComponent("messages")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let data = try encoder.encode(message)
            try? await URLSession.shared.upload(for: request, from: data)
        }
    }
    
    func fetchConversations() async throws -> [Conversation] {
        let url = baseURL.appendingPathComponent("conversations")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode([Conversation].self, from: data)
    }

    func fetchMessages() async throws -> [Message] {
        let url = baseURL.appendingPathComponent("messages")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode([Message].self, from: data)
    }
    
    func getMockConversations() -> [Conversation] {
        return [
            Conversation(id: 1, customer_name: "Reyes Herzog", service_provider_name: "Colton Ruecker", state: .quoted, created_at: .now, updated_at: .now),
            Conversation(id: 2, customer_name: "Alycia Homenick", service_provider_name: "Amparo West", state: .rejected, created_at: .now, updated_at: .now)
        ]
    }
    
    func getMockMessages() -> [Message] {
        return [Message(id: 1, conversation_id: 1, message_type: .quote_offer, sender_type: .service_provider, text: "Hey,\nwe would like to work with you. Please accept our quote of $ 1.500", created_at: .now, read_at: .now),
                Message(id: 2, conversation_id: 1, message_type: .reject_quote_message, sender_type: .customer, text: "That's too expensive, sorry", created_at: .now, read_at: .now),
                Message(id: 3, conversation_id: 1, message_type: .quote_offer, sender_type: .service_provider, text: "Hey,\nwe would like to work with you. Please accept our quote of $ 1.500", created_at: .now, read_at: .now),
                Message(id: 4, conversation_id: 1, message_type: .reject_quote_message, sender_type: .customer, text: "Still to expensive", created_at: .now, read_at: nil),
        ]
    }
    
}

struct Conversation: Codable, Identifiable {
    var id: Int
    var customer_name: String
    var service_provider_name: String
    var state: ConversationState
    var created_at: Date
    var updated_at: Date
    var deleted_at: Date?
}

enum ConversationState: String, Codable {
    case quoted
    case rejected
    case accepted
}

struct Message: Codable, Identifiable {
    var id: Int
    var conversation_id: Int
    var message_type: MessageType
    var sender_type: SenderType
    var text: String
    var created_at: Date
    var read_at: Date?
    var attachments: [String] = []
}

enum MessageType: String, Codable {
    case quote_offer
    case reject_quote_message
    case accept_quote_message
    case standard_message
    case review_request
    case review
}

enum SenderType: String, Codable {
    case service_provider
    case customer
}

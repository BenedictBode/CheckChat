//
//  DataModel.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 30.11.23.
//

import Foundation

class DataModel: ObservableObject {
    
    static let shared = DataModel()
    
    @Published var messages: [Message] = []
    @Published var conversations: [Conversation] = []
    @Published var viewType: SenderType = .customer
    
    init() {
        messages = getMockMessages()
        conversations = getMockConversations()
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
}

struct Message: Codable, Identifiable {
    var id: Int
    var conversation_id: Int
    var message_type: MessageType
    var sender_type: SenderType
    var text: String
    var created_at: Date
    var read_at: Date?
}

enum MessageType: String, Codable {
    case quote_offer
    case reject_quote_message
}

enum SenderType: String, Codable {
    case service_provider
    case customer
}

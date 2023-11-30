//
//  ChatView.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 30.11.23.
//

import SwiftUI

struct ConversationDetailView: View {
    
    let conversation: Conversation
    @ObservedObject var dataModel = DataModel.shared
    
    @State private var messageText: String = ""
    
    var messages: [Message] {
        dataModel.messages.filter { $0.conversation_id == conversation.id}
    }

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages) { message in
                    ChatBubble(message: message, viewerSenderType: dataModel.viewType)
                }
            }
            Spacer()
            HStack {
                TextField("Type a message...", text: $messageText)
                    .lineLimit(5)
                    .textFieldStyle(.roundedBorder)

                Button {
                    withAnimation {
                        dataModel.messages.append(Message(id: messages.count + 1, conversation_id: conversation.id, message_type: .reject_quote_message, sender_type: dataModel.viewType, text: messageText, created_at: .now))
                    }
                    messageText = ""
                } label: {
                    Image(systemName: "paperplane")
                }
                .disabled(messageText.isEmpty)
            }
        }
        .padding(.horizontal)
    }
}

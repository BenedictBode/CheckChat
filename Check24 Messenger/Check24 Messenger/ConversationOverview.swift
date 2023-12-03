//
//  ConversationOverview.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 01.12.23.
//

import SwiftUI

struct ConversationOverview: View {
    
    @ObservedObject var dataModel = DataModel.shared
        
    var body: some View {
        List(dataModel.conversations) { conversation in
            NavigationLink {
                ConversationDetailView(conversation: conversation)
            } label: {
                HStack {
                    Image(dataModel.conversationName(conversation: conversation))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(dataModel.conversationName(conversation: conversation))
                            .font(.title2)
                        if let lastMessage = dataModel.messages.last(where: {$0.conversation_id == conversation.id && $0.sender_type == dataModel.otherViewType && $0.message_type != .review && $0.message_type != .review_request})?.text {
                            Text(lastMessage)
                                .font(.caption)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                    if conversation.state == .quoted {
                        Image(systemName: "questionmark")
                    } else if conversation.state == .rejected {
                        Image(systemName: "xmark")
                    } else {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

#Preview {
    ConversationOverview()
}

//
//  SystemBubble.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 01.12.23.
//

import SwiftUI

struct SystemBubble: View {
    var message: Message
    let conversation: Conversation
    
    @ObservedObject var dataModel = DataModel.shared
    
    var otherSenderType: SenderType {
        dataModel.viewType == .customer ? .service_provider : .customer
    }

    private var bubbleColor: Color {
        return message.message_type == .accept_quote_message ? .green : .red
    }

    private var text: String {
        if dataModel.viewType == .customer {
            if message.message_type == .accept_quote_message {
                return "You're interested."
            } else {
                return "You rejected."
            }
        } else {
            if message.message_type == .accept_quote_message {
                return "Customer is interested 🎉"
            } else {
                return "Customer rejected."
            }
        }
    }
    
    

    var body: some View {
        HStack {
            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                
                Text(text)
                
            }
            .padding(10)
            .background(bubbleColor)
            .cornerRadius(15)
            .foregroundColor(.white)

            Spacer()
        }
    }
}

//
//  ChatBubble.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 30.11.23.
//

import SwiftUI

struct ChatBubble: View {
    var message: Message
    let viewerSenderType: SenderType
    var otherSenderType: SenderType {
        viewerSenderType == .customer ? .service_provider : .customer
    }

    private var bubbleColor: Color {
        return message.sender_type == viewerSenderType ? .blue : .gray
    }

    private var readStatusIcon: some View {
        Image(systemName: message.read_at != nil ? "checkmark.seal.fill" : "checkmark.seal")
            .foregroundColor(.white)
            .font(.caption)
            .opacity(message.read_at != nil ? 1.0 : 0.5)  // More opaque if read
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: message.created_at)
    }

    var body: some View {
        HStack {
            if message.sender_type == viewerSenderType {
                Spacer()
            }

            VStack(alignment: .trailing, spacing: 8) {
                Text(message.text)

                HStack {
                    Text(formattedTime)
                        .font(.caption)
                        .foregroundColor(.white)
                    if message.sender_type == viewerSenderType {
                        readStatusIcon
                    }
                }
            }
            .padding(10)
            .background(bubbleColor)
            .cornerRadius(15)
            .foregroundColor(.white)

            if message.sender_type == otherSenderType {
                Spacer()
            }
        }
    }
}

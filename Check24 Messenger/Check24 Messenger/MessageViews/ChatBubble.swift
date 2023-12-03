//
//  ChatBubble.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 30.11.23.
//

import SwiftUI

struct ChatBubble: View {
    
    
    var message: Message
    let conversation: Conversation
    
    @ObservedObject var dataModel = DataModel.shared
    private var bubbleColor: Color {
        return message.sender_type == dataModel.viewType ? .accent : .gray
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
    
    func detectAndMaskContactData(in text: String) -> String {
        var maskedText = text
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link, .address]
        let detector = try? NSDataDetector(types: types.rawValue)

        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) ?? []
        for match in matches.reversed() { // Process in reverse to not mess up the indices
            let range = Range(match.range, in: text)!
            //if range.count <= 2 { continue } // Skip if the range is too small to be masked

            let firstCharIndex = text.index(range.lowerBound, offsetBy: 1)
            let lastCharIndex = text.index(range.upperBound, offsetBy: -1)
            let maskRange = firstCharIndex..<lastCharIndex
            
            let maskString = String(repeating: "*", count: text.distance(from: firstCharIndex, to: lastCharIndex))
            maskedText.replaceSubrange(maskRange, with: maskString)
        }

        return maskedText
    }

    
    var text: String {
        
        if (conversation.state == .quoted || conversation.state == .rejected) && dataModel.viewType == .customer {
            return detectAndMaskContactData(in: message.text)
        }
        return message.text
    }

    var body: some View {
        HStack {
            if message.sender_type == dataModel.viewType {
                Spacer()
            }

            VStack(alignment: .trailing, spacing: 8) {
                
                if !message.attachments.isEmpty {
                    ForEach(message.attachments, id: \.self) { fileName in
                        if DataModel.isImage(fileName: fileName) {
                            AsyncImage(url: DataModel.downloadURL(conversationId: conversation.id, messageId: message.id, fileName: fileName)) { content in
                                content
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipShape(RoundedRectangle(cornerSize: .init(width: 15, height: 15)))
                                    .padding(1)
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipShape(RoundedRectangle(cornerSize: .init(width: 15, height: 15)))
                                    .padding(1)
                            }
                        } else {
                            Button {
                                
                            } label: {
                                HStack(spacing: 2) {
                                    Text(fileName)
                                    Image(systemName: "doc")
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        
                    }
                }
                
                Text(text)
                
                HStack {
                    Text(formattedTime)
                        .font(.caption)
                        .foregroundColor(.white)
                    if message.sender_type == dataModel.viewType {
                        readStatusIcon
                    }
                }
            }
            .padding(10)
            .background(bubbleColor)
            .cornerRadius(15)
            .foregroundColor(.white)

            if message.sender_type == dataModel.otherViewType {
                Spacer()
            }
        }
    }
}

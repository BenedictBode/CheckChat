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
    @State var filePickerIsPresented: Bool = false
    @State var attachments: [URL] = []
    @State var firstUnreadMessage: Message?
    @State var unreadCount = 0
    
    var pendingMessageId: Int {
        var pendingMessageId = -1
        messages.forEach { message in
            if message.message_type == .quote_offer {
                pendingMessageId = message.id
            } else if message.message_type == .accept_quote_message || message.message_type == .reject_quote_message {
                pendingMessageId = -1
            }
        }
        return pendingMessageId
    }
    
    var nextMessageId: Int {
        messages.count + 1
    }
    
    var messages: [Message] {
        dataModel.messages.filter { $0.conversation_id == conversation.id}
    }
    
    var noChat: Bool {
        (dataModel.viewType == .service_provider && conversation.state == .quoted && messages.count == 1) || conversation.state == .rejected
    }
    
    var chatInfo: String {
        if conversation.state == .rejected {
            if dataModel.viewType == .customer {
                return "You rejected the conversation."
            } else {
                return "Customer rejected the conversation."
            }
        } else if noChat {
            return "Customer has to respond first."
        } else {
            return "Type a message..."
        }
    }

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(messages) { message in
                    
                    if message.id == firstUnreadMessage?.id {
                        UnreadBanner(unreadCount: unreadCount)
                    }
                    
                    if message.message_type == .accept_quote_message || message.message_type == .reject_quote_message {
                        SystemBubble(message: message, conversation: conversation)
                    } else if message.message_type == .review_request {
                        if !messages.contains(where: {$0.message_type == .review}) {
                            ReviewBubble(message: message, conversation: conversation) { starCount in
                                sendMessage(text: "\(starCount)/5", messageType: .review, attachments: [])
                            }
                        }
                    } else if message.message_type == .review  {
                        ReviewedBubble(message: message, conversation: conversation)
                    } else {
                        ChatBubble(message: message, conversation: conversation)
                    }
                    if message.id == pendingMessageId && dataModel.viewType == .customer {
                        HStack {
                            Button(role: .destructive) {
                                sendMessage(text: "I reject the quote.", messageType: .reject_quote_message, attachments: attachments)
                            } label: {
                                Image(systemName: "xmark")
                            }
                            Button(role: .none) {
                                sendMessage(text: "I accept the quote.", messageType: .accept_quote_message, attachments: attachments)
                            } label: {
                                Image(systemName: "checkmark")
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            Spacer()
            
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(attachments, id: \.absoluteString) { attachment in
                            if DataModel.isImage(fileName: attachment.lastPathComponent) {
                                AsyncImage(url: attachment) { content in
                                    content
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerSize: .init(width: 5, height: 5)))
                                        .padding(1)
                                } placeholder: {
                                    Image(systemName: "photo")
                                }
                            } else {
                                Button {
                                    
                                } label: {
                                    HStack(spacing: 2) {
                                        Text(attachment.lastPathComponent)
                                        Image(systemName: "doc")
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                ScrollView(.horizontal) {
                    if conversation.state == .accepted && dataModel.viewType == .service_provider && !messages.contains(where: {$0.message_type == .review_request}) {
                        if let acceptanceDate = messages.last(where: {$0.message_type == .accept_quote_message})?.created_at, isMoreThanSevenDaysAgo(date: acceptanceDate) {
                            Button {
                                sendMessage(text: "Hey review please", messageType: .review_request, attachments: [])
                            } label: {
                                Text("request review")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                HStack {
                    Button {
                        filePickerIsPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .fileImporter(isPresented: $filePickerIsPresented, allowedContentTypes: [.image, .pdf], allowsMultipleSelection: true) { result in
                        if let urls = try? result.get() {
                            urls.forEach { url in
                                dataModel.uploadFile(fileURL: url, conversation_id: conversation.id, message_id: nextMessageId)
                                attachments.append(url)
                            }
                        }
                    }
                    TextField(chatInfo, text: $messageText)
                        .lineLimit(5)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        var messageType: MessageType = .standard_message
                        if messages.count == 0 && dataModel.viewType == .service_provider {
                            messageType = .quote_offer
                        }
                        sendMessage(text: messageText, messageType: messageType, attachments: attachments)
                        messageText = ""
                        attachments = []
                    } label: {
                        Image(systemName: "paperplane")
                    }
                    .disabled(messageText.isEmpty && attachments.isEmpty)
                    
                }
            }
            .disabled(noChat)
        }
        .padding(.horizontal, 5)
        .navigationTitle(dataModel.conversationName(conversation: conversation))
        .navigationBarItems(trailing:
            Image(dataModel.conversationName(conversation: conversation))
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
        )
        .onChange(of: dataModel.messages.count, initial: true) { oldValue, newValue in
            markMessagesAsRead()
        }
        .onAppear() {
            firstUnreadMessage = messages.first(where: { $0.sender_type == dataModel.otherViewType && $0.read_at == nil})
            unreadCount = messages.filter{ $0.sender_type == dataModel.otherViewType && $0.read_at == nil}.count
        }
    }
    
    func sendMessage(text: String, messageType: MessageType, attachments: [URL]) {
        let message = Message(id: nextMessageId,
                              conversation_id: conversation.id,
                              message_type: messageType,
                              sender_type: dataModel.viewType,
                              text: text,
                              created_at: .now,
                              attachments: attachments.map { $0.lastPathComponent })
        try? dataModel.uploadMessage(message: message)
        dataModel.messages.append(message)
        
        var conversation = conversation
        if messageType == .accept_quote_message {
            conversation.state = .accepted
            dataModel.updateConversation(conversation: conversation)
        } else if messageType == .reject_quote_message {
            conversation.state = .rejected
            dataModel.updateConversation(conversation: conversation)
        }
    }
    
    func isMoreThanSevenDaysAgo(date: Date) -> Bool {
        let calendar = Calendar.current
        if let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) {
            return date < sevenDaysAgo
        }
        return false
    }
    
    func markMessagesAsRead() {
        messages.filter { $0.sender_type == dataModel.otherViewType && $0.read_at == nil }
            .forEach { message in
                var message = message
                message.read_at = .now
                dataModel.updateMessage(message: message)
            }
    }
}


struct UnreadBanner: View {
    
    var unreadCount: Int
    
    var text: String {
        if unreadCount < 2 {
            return String(unreadCount) + " unread message"
        } else {
            return String(unreadCount) + " unread messages"
        }
    }
    
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .cornerRadius(5)
            .background(Color.gray.opacity(0.6))
            .ignoresSafeArea()
    }
}

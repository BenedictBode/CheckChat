//
//  ReviewBubble.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 02.12.23.
//

import SwiftUI

struct ReviewBubble: View {
    
    var message: Message
    let conversation: Conversation
    
    @ObservedObject var dataModel = DataModel.shared
    
    @State private var rating: Int = 0
    
    let review: (Int) -> Void

    private var bubbleColor: Color {
        return .teal
    }

    private var text: String {
        if dataModel.viewType == .customer {
            return "\(conversation.service_provider_name) kindly asks you to leave a review."
        } else {
            return "review requested."
        }
    }
    
    var body: some View {
        HStack {
            Spacer()

            VStack(alignment: .center, spacing: 8) {
                
                Text(text)
                
                if dataModel.viewType == .customer {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star > rating ? "star" : "star.fill")
                                .foregroundColor(star > rating ? Color.gray : Color.yellow)
                                .onTapGesture {
                                    self.rating = star
                                    review(rating)
                                }
                        }
                    }
                    .font(.title2)
                }
                
            }
            .padding(10)
            .background(bubbleColor)
            .cornerRadius(15)
            .foregroundColor(.white)

            Spacer()
        }
        
    }
}

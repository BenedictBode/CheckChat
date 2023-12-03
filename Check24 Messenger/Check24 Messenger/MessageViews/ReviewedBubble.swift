//
//  ReviewedBubble.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 03.12.23.
//

import SwiftUI

struct ReviewedBubble: View {
    var message: Message
    let conversation: Conversation
    
    @ObservedObject var dataModel = DataModel.shared

    private var bubbleColor: Color {
        return .green
    }

    private var text: String {
        if dataModel.viewType == .customer {
            return "You reviewed."
        } else {
            return "Customer reviewed."
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

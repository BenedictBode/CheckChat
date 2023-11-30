//
//  ContentView.swift
//  Check24 Messenger
//
//  Created by Benedict Bode on 30.11.23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var dataModel = DataModel.shared
        
    var body: some View {
        NavigationView {
            List(dataModel.conversations) { conversation in
                NavigationLink(destination: ConversationDetailView(conversation: conversation)) {
                    Text(dataModel.viewType == .customer ? conversation.service_provider_name : conversation.customer_name)
                }
            }
            .navigationTitle("Conversations")
        }
    }
}


#Preview {
    ContentView()
}

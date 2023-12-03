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
            ConversationOverview()
                .navigationBarTitle("Conversations")
                .navigationBarItems(trailing:
                    HStack {
                        Button {
                            dataModel.reset()
                        } label: {
                            Image(systemName: "arrow.counterclockwise.icloud")
                        }
                        Button(dataModel.viewType.rawValue) {
                            if dataModel.viewType == .customer {
                                dataModel.viewType = .service_provider
                            } else {
                                dataModel.viewType = .customer
                            }
                        }
                    }
                )
        }
    }
}


#Preview {
    ContentView()
}

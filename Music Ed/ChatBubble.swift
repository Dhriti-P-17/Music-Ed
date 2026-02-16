//
//  ChatBubble.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 2/13/26.
//

import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading) {
                if !message.text.isEmpty {
                    Text(message.text)
                }
                
                // Show file names if they exist
                if let files = message.attachmentNames {
                    ForEach(files, id: \.self) { fileName in
                        HStack {
                            Image(systemName: "paperclip")
                            Text(fileName)
                        }
                        .font(.caption)
                        .padding(.top, 4)
                    }
                }
            }
            .padding(12)
            .background(message.isUser ? Color.pink : Color(.systemGray5))
            .foregroundColor(message.isUser ? .white : .primary)
            .cornerRadius(16)
            
            if !message.isUser { Spacer() }
        }
    }
}


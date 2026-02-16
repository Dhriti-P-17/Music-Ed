//
//  ChatMessage.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 2/13/26.
//

import Foundation
import SwiftData

struct ChatMessage: Identifiable {
    let id = UUID()
    var text: String
    var isUser: Bool
    // Add this line below to fix the error:
    var attachmentNames: [String]?
    var timestamp = Date()
};var timestamp: Date = Date()


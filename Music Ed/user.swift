//
//  user.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 2/8/26.
//

import Foundation
import SwiftData

@Model
class UserAccount {
    // Every property must have a default value or be optional for iCloud sync
    var username: String = ""
    var password: String = ""
    
    init(username: String = "", password: String = "") {
        self.username = username
        self.password = password
    }
}

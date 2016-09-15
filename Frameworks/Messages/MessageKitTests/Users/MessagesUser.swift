//
//  MessagesUser.swift
//  Messages
//
//  Created by Nathan Armstrong on 7/1/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoAutomated
import CoreData

class User1: User {
    init() {
        super.init(credentials: Credentials.user1Beta)
    }
}

class User2: User {
    init() {
        super.init(credentials: Credentials.user2Beta)
    }
}

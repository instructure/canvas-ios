//
//  Conversation.swift
//  Messages
//
//  Created by Nathan Armstrong on 6/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import MessageKit
import CoreData
import TooLegit
import SoPersistent
import SoAutomated

extension Conversation {
    static func build(context: NSManagedObjectContext) -> Conversation {
        let conversation = Conversation(inContext: context)
        return conversation
    }
}

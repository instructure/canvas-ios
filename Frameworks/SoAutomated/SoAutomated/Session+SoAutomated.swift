//
//  Session+SoAutomated.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 7/6/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import TooLegit
import CoreData

extension Session {
    public convenience init(baseURL: NSURL, user: SessionUser, token: String?, unitTesting: Bool) {
        self.init(baseURL: baseURL, user: user, token: token)
        if unitTesting {
            storeType = NSInMemoryStoreType
        }
    }
}


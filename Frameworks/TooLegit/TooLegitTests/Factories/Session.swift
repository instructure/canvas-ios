//
//  Session.swift
//  TooLegit
//
//  Created by Nathan Armstrong on 6/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit

extension Session {
    static func build(baseURL baseURL: String = "http://google.com",
                      userID: String = "1",
                      userName: String = "john",
                      token: String? = nil,
                      masqueradeAsUserID: String? = nil,
                      localStoreDirectory: Session.LocalStoreDirectory = .Default) -> Session {
        let url = NSURL(string: baseURL)!
        let user = SessionUser(id: userID, name: userName)
        return Session(baseURL: url, user: user, token: token, localStoreDirectory: localStoreDirectory, masqueradeAsUserID: masqueradeAsUserID)
    }
}

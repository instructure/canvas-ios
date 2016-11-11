//
//  MockClient.swift
//  Canvas
//
//  Created by Nathan Armstrong on 9/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoAutomated
import CanvasKeymaster

class MockClient: CKIClient {
    var mockUser: User!

    init(user: User) {
        super.init(baseURL: user.session.baseURL, token: user.session.token)
        self.mockUser = user
    }

    override var currentUser: CKIUser {
        let user = CKIUser()
        user.loginID = mockUser.id
        return user
    }


    // MARK: Required Stuff

    override init(baseURL url: NSURL?, sessionConfiguration configuration: NSURLSessionConfiguration?) {
        super.init(baseURL: url, sessionConfiguration: configuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

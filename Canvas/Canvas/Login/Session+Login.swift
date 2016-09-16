//
//  Session+LoggedInSession.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CanvasKeymaster
import TooLegit
import SoLazy


let TheKeymaster = CanvasKeymaster.theKeymaster()


extension CKIUser {
    private var sessionUser: SessionUser {
        return SessionUser(id: id, name: name, loginID: loginID, sortableName: sortableName, email: email, avatarURL: avatarURL)
    }
}

extension CKIClient {
    private var legitSession: Session {
        guard let url = baseURL else { ❨╯°□°❩╯⌢"The client doesn't have a baseURL?" }
        return Session(baseURL: url, user: currentUser.sessionUser, token: accessToken, masqueradeAsUserID: self.actAsUserID)
    }
}

extension Session {
    static var loginSignalProducer: SignalProducer<Session, NSError> {
        return CanvasKeymaster
            .theKeymaster()
            .signalForLogin
            .toSignalProducer()
            .startOn(UIScheduler())
            .map { $0 as! CKIClient }
            .map { $0.authSession }
    }
    
    static var logoutSignalProducer: SignalProducer<UIViewController, NSError> {
        return CanvasKeymaster
            .theKeymaster()
            .signalForLogout
            .toSignalProducer()
            .startOn(UIScheduler())
            .map { $0 as! UIViewController }
    }
}
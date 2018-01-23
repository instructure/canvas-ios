//
//  CKIClient+Extensions.swift
//  CanvasCore
//
//  Created by Garrett Richards on 1/18/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

private var sessionAssociationKey: UInt8 = 0

extension CKIUser {
    func sessionUser() -> SessionUser {
        return SessionUser(id: id, name: name, loginID: loginID, sortableName: sortableName, email: email, avatarURL: avatarURL)
    }
}

extension CKIClient {
    public var authSession: Session {
        if let session = objc_getAssociatedObject(self, &sessionAssociationKey) as? Session {
            return session
        }
        
        let url = baseURL ?? URL(string: "")!
        var masqueradeID: String? = nil
        if let actAsUserID = actAsUserID, actAsUserID.count > 0 { masqueradeID = actAsUserID }
        let session = Session(baseURL: url, user: currentUser.sessionUser(), token: accessToken, masqueradeAsUserID: masqueradeID)
        objc_setAssociatedObject(self, &sessionAssociationKey, session, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return session
    }
}

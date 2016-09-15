//
//  SettingsViewModel.swift
//  Parent
//
//  Created by Brandon Pluim on 1/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

import TooLegit
import Result

class SettingsViewModel {
    var objects: [SessionUser] = []
    let session: Session
    
    init(session: Session) {
        self.session = session
    }
    
    // ---------------------------------------------
    // MARK: - Header Fields
    // ---------------------------------------------
    func nameText() -> String {
        return session.user.name
    }
    
    func emailText() -> String {
        return session.user.email ?? ""
    }
    
}
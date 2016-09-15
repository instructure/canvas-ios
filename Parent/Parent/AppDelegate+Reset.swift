//
//  AppDelegate+Reset.swift
//  Parent
//
//  Created by Brandon Pluim on 7/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import Keymaster
import SoLazy

extension AppDelegate {
    static func resetApplicationForTesting() {
        resetKeychainForTesting()
        resetDirectoriesForTesting()

        Router.sharedInstance.routeToLoggedOutViewController()
    }

    static func resetCacheForTesting() {
        resetDirectoriesForTesting()

        Keymaster.sharedInstance.useSharedCredentials = false
        if let session = Keymaster.sharedInstance.mostRecentSession() {
            Keymaster.sharedInstance.currentSession = session
            Router.sharedInstance.session = session
            Router.sharedInstance.routeToLoggedInViewController()
        } else {
            Router.sharedInstance.routeToLoggedOutViewController()
        }
    }

    static func resetKeychainForTesting() {
        let keymaster = Keymaster.sharedInstance
        for session in keymaster.savedSessions() {
            keymaster.deleteSession(session)
        }
    }

    static func resetDirectoriesForTesting() {
        let fileManager = NSFileManager.defaultManager()
        guard let libURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first,
            docURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
                ❨╯°□°❩╯⌢"GASP! There were no user library search paths"
        }

        for dirURL in [libURL, docURL] {
            let files = try! fileManager.contentsOfDirectoryAtURL(dirURL, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles)
            for file in files {
                try! fileManager.removeItemAtURL(file)
            }
        } 
    }
}
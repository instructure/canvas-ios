//
//  AppDelegate+Reset.swift
//  Teach
//
//  Created by Brandon Pluim on 7/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import Keymaster
import SoLazy

extension AppDelegate {
    func resetApplicationForTesting() {
        resetKeychainForTesting()
        resetDirectoriesForTesting()

        window?.rootViewController = UINavigationController(rootViewController: domainPicker())
    }

    func resetCacheForTesting() {
        resetDirectoriesForTesting()

        window?.rootViewController = navigator?.rootViewController
    }

    func resetKeychainForTesting() {
        let keymaster = Keymaster.sharedInstance
        for session in keymaster.savedSessions() {
            keymaster.deleteSession(session)
        }
    }

    func resetDirectoriesForTesting() {
        let fileManager = NSFileManager.defaultManager()
        guard let libURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first,
            docURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
                ❨╯°□°❩╯⌢"GASP! There were no user library search paths"
        }

        for dirURL in [libURL, docURL] {
            let files = try! fileManager.contentsOfDirectoryAtURL(dirURL, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles)
            for file in files {
                let _ = try? fileManager.removeItemAtURL(file)
            }
        } 
    }
}
//
//  AppReset.swift
//  CanvasCore
//
//  Created by Layne Moseley on 4/27/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

public func ResetAppIfNecessary() {
    let reset = UserDefaults.standard.bool(forKey: "reset_cache_on_next_launch")
    if (reset) {
        ResetApp()
        CanvasKeymaster.the().logout()
        UserDefaults.standard.set(false, forKey: "reset_cache_on_next_launch")
        UserDefaults.standard.synchronize()
    }
}

public func ResetApp() {
    // Clear the keychain
    FXKeychain.shared().clear()
    
    let fm = FileManager.default
    
    // Clear the entire contents of the app directories where we store stuffs
    let directories: [FileManager.SearchPathDirectory] = [.documentDirectory, .libraryDirectory, .cachesDirectory]
    directories.forEach {
        if let folderPath = NSSearchPathForDirectoriesInDomains($0, .userDomainMask, true).first {
            if let contents = try? fm.contentsOfDirectory(atPath: folderPath) {
                contents.forEach {
                    let itemPath = (folderPath as NSString).appendingPathComponent($0)
                    try? fm.removeItem(atPath: itemPath)
                }
            }
        }
    }
    
    // Clear out the users core data cache and other things in the app group container
    if let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: LocalStoreAppGroupName),
        let contents = try? fm.contentsOfDirectory(at: appGroup, includingPropertiesForKeys: nil, options: []) {
            contents.forEach {
                try? fm.removeItem(at: $0)
            }
    }
}

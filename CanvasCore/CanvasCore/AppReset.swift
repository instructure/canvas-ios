//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

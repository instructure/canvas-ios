//
// Copyright (C) 2016-present Instructure, Inc.
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
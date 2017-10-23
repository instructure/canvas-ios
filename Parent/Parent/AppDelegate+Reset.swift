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
import CanvasCore


extension AppDelegate {
    static func resetRegionForTesting() {
      RegionPicker.shared.isBeta.value = true
    }

    static func logout() {
        // Prevent a memory leak after setting window.rootViewController while another view is presented
        // like in settings with the log out action sheet.
        // see rdar://21404408
        if let
            window = Router.sharedInstance.applicationWindow(),
            let rootNav = window.rootViewController as? UINavigationController,
            let topViewController = rootNav.topViewController, topViewController.presentedViewController != nil
        {
            topViewController.dismiss(animated: false) {
                Router.sharedInstance.routeToLoggedOutViewController()
            }
            return
        }

        Router.sharedInstance.routeToLoggedOutViewController()
    }

    static func resetApplicationForTesting() {
        AppDelegate.resetRegionForTesting()
        AppDelegate.resetKeychainForTesting()
        AppDelegate.resetCacheForTesting()
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
        keymaster.logout()
        for session in keymaster.savedSessions() {
            keymaster.deleteSession(session)
        }
    }

    static func resetDirectoriesForTesting() {
        let fileManager = FileManager.default
        guard let libURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first,
            let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                ❨╯°□°❩╯⌢"GASP! There were no user library search paths"
        }

        for dirURL in [libURL, docURL] {
            let files = try! fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for file in files {
              let notEarlGreyScreenshot = !file.absoluteString.contains("earlgrey_screenshots")

              if notEarlGreyScreenshot {
                try? fileManager.removeItem(at: file)
              }
            }
        } 
    }
}

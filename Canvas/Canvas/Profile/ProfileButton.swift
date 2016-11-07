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
    
    

import UIKit
import Peeps
import ReactiveCocoa
import TooLegit
import TechDebt
import Kingfisher

func addProfileButton(session: Session, viewController: UIViewController) {
    let profileButton = ProfileBarButtonItem(avatarURL: session.user.avatarURL)
    let enrollments = viewController
    
    profileButton.rac_command = RACCommand() { [unowned profileButton, enrollments] _ in
        let profile = ProfileViewController()
        profile.settingsViewControllerFactory = {
            return SettingsViewController.controller(CKCanvasAPI.currentAPI())
        }
        profile.canvasAPI = CKCanvasAPI.currentAPI()
        profile.user = profile.canvasAPI.user
        profile.profileImageSelected = { newProfileImage in
            if let key = session.user.avatarURL?.absoluteString {
                KingfisherManager.sharedManager.cache.storeImage(newProfileImage, forKey: key)
            }
            
            profileButton.setProfileImage(newProfileImage)
        }
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
        doneButton.rac_command = RACCommand() { [weak profile] _ in
            profile?.dismissViewControllerAnimated(true, completion: nil)
            return .empty()
        }
        profile.navigationItem.leftBarButtonItem = doneButton
        let nav = UINavigationController(rootViewController: profile)
        nav.modalPresentationStyle = .FormSheet
        enrollments.presentViewController(nav, animated: true, completion: nil)
        return .empty()
    }
    enrollments.navigationItem.leftBarButtonItem = profileButton
}
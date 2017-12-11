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
import ReactiveSwift
import TechDebt
import Kingfisher
import CanvasCore

let transitioningDelegate = DrawerTransitionDelegate()

func profileController(_ session: Session) -> UINavigationController {
    let profile = ProfileViewController()
    profile.settingsViewControllerFactory = {
        return SettingsViewController.controller(CKCanvasAPI.current())
    }
    profile.canvasAPI = CKCanvasAPI.current()
    profile.user = profile.canvasAPI.user
    profile.profileImageSelected = { newProfileImage in
        if let key = session.user.avatarURL?.absoluteString {
            if let image = newProfileImage {
                KingfisherManager.shared.cache.store(image, forKey: key)
            } else {
                KingfisherManager.shared.cache.removeImage(forKey: key)
            }
        }
    }
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    doneButton.rac_command = RACCommand() { [weak profile] _ in
        profile?.dismiss(animated: true, completion: nil)
        return .empty()
    }
    profile.navigationItem.leftBarButtonItem = doneButton
    return UINavigationController(rootViewController: profile)
}

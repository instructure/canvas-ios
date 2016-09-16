//
//  Profile.swift
//  Canvas
//
//  Created by Derrick Hathaway on 5/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
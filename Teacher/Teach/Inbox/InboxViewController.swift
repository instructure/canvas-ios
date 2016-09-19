//
//  InboxViewController.swift
//  Teach
//
//  Created by Derrick Hathaway on 6/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import SoIconic

private let inboxTitle = NSLocalizedString("Inbox", comment: "Title for Inbox view")
class InboxViewController: UIViewController {
    static func tab(session: Session, route: RouteAction) throws -> UIViewController {
        let nav = UINavigationController(rootViewController: InboxViewController())
        nav.tabBarItem.title = inboxTitle
        nav.tabBarItem.image = .icon(.inbox)
        nav.tabBarItem.selectedImage = .icon(.inbox, filled: true)
        return nav
    }
}

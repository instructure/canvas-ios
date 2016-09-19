//
//  WeekViewController.swift
//  Teach
//
//  Created by Derrick Hathaway on 6/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit

private let weeksTitle = NSLocalizedString("Weeks", comment: "Title for the weeks calendar view")
class WeekViewController: UIViewController {
    static func tab(session: Session, route: RouteAction) throws -> UIViewController {
        let nav = UINavigationController(rootViewController: WeekViewController())
        nav.tabBarItem.title = weeksTitle
        nav.tabBarItem.image = .icon(.calendar)
        nav.tabBarItem.selectedImage = .icon(.calendar, filled: true)
        return nav
    }
}

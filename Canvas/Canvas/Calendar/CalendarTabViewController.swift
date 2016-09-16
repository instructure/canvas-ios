//
//  CalendarTabViewController.swift
//  iCanvas
//
//  Created by Brandon Pluim on 4/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPretty
import TooLegit
import CalendarKit
import TechDebt

public func CalendarTabViewController(session session: Session, route: (UIViewController, NSURL)->()) throws -> UIViewController {
    let calendarTitle = NSLocalizedString("Calendar", comment: "Calendar page title")

    let calendarVC: UIViewController
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
        let monthVC = CalendarMonthViewController.new(session)
        monthVC.routeToURL = { [unowned monthVC] url in
            route(monthVC, url)
        }
        calendarVC = monthVC
    } else {
        let splitVC = CalendarSplitMonthViewController.new(session)
        splitVC.routeToURL = { [unowned splitVC] url in
            route(splitVC, url)
        }
        calendarVC = splitVC
    }
    
    calendarVC.tabBarItem.title = calendarTitle
    calendarVC.tabBarItem.image = UIImage.techDebtImageNamed("icon_calendar_tab")
    calendarVC.tabBarItem.selectedImage = UIImage.techDebtImageNamed("icon_calendar_tab_selected")

    return calendarVC
}
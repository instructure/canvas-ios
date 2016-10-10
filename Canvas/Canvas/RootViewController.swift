//
//  RootViewController.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 3/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import UIKit
import SoLazy
import EnrollmentKit
import CalendarKit
import ReactiveCocoa
import Kingfisher
import TechDebt
import TooLegit
import Peeps


func rootViewController(session: Session) -> UIViewController {
    let tabs = CanvasTabBar()
    
    do {
        // ENROLLMENTS
        let enrollments = try EnrollmentsViewController(session: session) { vc, url in
            Router.sharedRouter().routeFromController(vc, toURL: url)
        }

        addProfileButton(session, viewController: enrollments)
        let enrollmentsNav = UINavigationController(rootViewController: enrollments)

        // CALENDAR
        let calendar = try CalendarTabViewController(session: session) { vc, url in
            Router.sharedRouter().routeFromController(vc, toURL: url)
        }
        let calendarNav = UINavigationController(rootViewController: calendar)

        // TODO
        let todo = try ToDoTabViewController(session: session) { vc, url in
            Router.sharedRouter().routeFromController(vc, toURL: url)
        }
        let todoNav = UINavigationController(rootViewController: todo)

        tabs.viewControllers = [
            enrollmentsNav,
            calendarNav,
            todoNav,
            NotificationsTab(),
            UIViewController.messagesTab()
        ]
    } catch let e as NSError {
        delay(0.1) {
            e.report(alertUserFrom: tabs)
        }
    }
    
    let selectedTab = UserPreferences.landingPage(session.user.id)
    tabs.selectedIndex = selectedTab.tabIndex

    return tabs
}

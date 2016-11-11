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
            MessagesTab()
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

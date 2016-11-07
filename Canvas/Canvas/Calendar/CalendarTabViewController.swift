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

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
    
    

import EnrollmentKit
import SoPretty
import TooLegit

public func EnrollmentsViewController(session session: Session, route: (UIViewController, NSURL)->()) throws -> UIViewController {
    let coursesTitle = NSLocalizedString("Courses", comment: "Courses page title")
    let coursesPage = ControllerPage(title: coursesTitle, controller: try CoursesCollectionViewController(session: session, route: route))
    
    let groupsTitle = NSLocalizedString("Groups", comment: "Groups page title")
    let groupsPage = ControllerPage(title: groupsTitle, controller: try GroupsCollectionViewController(session: session, route: route))
    
    let enrollments = PagedViewController(pages: [
        coursesPage,
        groupsPage
    ])
    
    enrollments.tabBarItem.title = coursesTitle
    enrollments.tabBarItem.image = UIImage.techDebtImageNamed("icon_courses_tab")
    enrollments.tabBarItem.selectedImage = UIImage.techDebtImageNamed("icon_courses_tab_selected")
    
    return enrollments
}
//
//  EnrollmentsViewController.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 3/21/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
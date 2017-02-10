//
//  CourseViewController.swift
//  Teacher
//
//  Created by Derrick Hathaway on 2/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import EnrollmentKit
import SixtySix
import SoPersistent
import TooLegit
import ReactiveSwift

func colorfulTab(_ tab: Tab) -> ColorfulViewModel {
    let colorful = ColorfulViewModel(features: [.icon])
    
    colorful.color <~ TEnv.current.session.enrollmentsDataSource.color(for: tab.contextID)
    colorful.title.value = tab.label
    colorful.icon.value = tab.icon
    
    return colorful
}

public class CourseViewController: Tab.TableViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tab = collection[indexPath]

        TEnv.current.router.route(to: tab.url, from: self)
    }
}


extension CourseViewController: Destination {
    public static func visit(with courseID: (String)) throws -> UIViewController {
        let course = CourseViewController()
        
        let session = TEnv.current.session
        let refresher = try Tab.refresher(session, contextID: .course(withID: courseID))
        let collection = try Tab.collection(session, contextID: .course(withID: courseID))
        course.prepare(collection, refresher: refresher, viewModelFactory: colorfulTab)
        
        return course
    }
}

//
//  PeopleViewController.swift
//  Teacher
//
//  Created by Derrick Hathaway on 2/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import SoPersistent
import Peeps
import SixtySix
import ReactiveSwift

func colorfulEnrollment(_ userEnrollment: UserEnrollment) -> ColorfulViewModel {
    let colorful = ColorfulViewModel(features: [.icon, .subtitle])
    
    colorful.color <~ TEnv.current.session.enrollmentsDataSource.color(for: .course(withID: userEnrollment.courseID))
    colorful.title.value = userEnrollment.user?.name ?? "No Name... that's weird"
    colorful.subtitle.value = userEnrollment.user?.email ?? ""
    
    return colorful
}


class PeopleViewController: UserEnrollment.TableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peep = collection[indexPath]
        
        TEnv.current.router.route(to: peep.url, from: self)
    }
}

extension PeopleViewController: Destination {
    static func visit(with courseID: (String)) throws -> UIViewController {
        let peeps = PeopleViewController()
        
        let session = TEnv.current.session
        let collection = try UserEnrollment.collectionByRole(enrolledInCourseWithID: courseID, for: session)
        let refresher = try UserEnrollment.refresher(enrolledInCourseWithID: courseID, for: session)
        
        peeps.prepare(collection, refresher: refresher, viewModelFactory: colorfulEnrollment)
        
        return peeps
    }
}

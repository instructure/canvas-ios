//
//  CoursesCollectionViewController.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import EnrollmentKit
import TooLegit
import SoIconic
import SoPretty

private func courseVM(course: Course, session: Session, presenter: UIViewController?) -> CourseViewModel {

    let contextID = course.contextID

    return CourseViewModel(enrollment: course,
       customize: { [weak presenter] button in
        let customize = CustomizeEnrollmentViewController(session: session, context: contextID)
        let nav = UINavigationController(rootViewController: customize)
        
        nav.modalPresentationStyle = .Popover
        nav.popoverPresentationController?.sourceView = button
        nav.popoverPresentationController?.sourceRect = button.bounds
        nav.preferredContentSize = CGSize(width: 320, height: 240)
        
        presenter?.presentViewController(nav, animated: true, completion: nil)
    }, makeAnAnnouncement: { [weak presenter] in
        
    })
}


private let coursesTitle = NSLocalizedString("Courses", comment: "Courses view title and nav button")
class CoursesCollectionViewController: Course.CollectionViewController {
    static func tab(session: Session, route: RouteAction) throws -> UIViewController {
        let nav = UINavigationController(rootViewController: try CoursesCollectionViewController(session: session, route: route))
        nav.tabBarItem.title = coursesTitle
        nav.tabBarItem.image = .icon(.course)
        nav.tabBarItem.selectedImage = .icon(.course, filled: true)
        return nav
    }
    
    let route: RouteAction
    
    init(session: Session, route: RouteAction) throws {
        self.route = route
        super.init()
        
        navigationItem.title = coursesTitle
        prepare(try Course.favoritesCollection(session), refresher: try Course.refresher(session)) { [weak self] course in
            return courseVM(course, session: session, presenter: self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let course = collection[indexPath]
        
        do {
            try route(self, NSURL(string: "/courses/\(course.id)")!)
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }
    }
}

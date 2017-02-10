//
//  Router+TeacherKit.swift
//  Teacher
//
//  Created by Derrick Hathaway on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation
import SixtySix
import Pathetic
import SafariServices

private let apiV1 = /?"api"/"v1"
private let courses = apiV1/?"courses"
private let course = courses/string
private let assignments = course/"assignments"
private let people = course/"users"
private let person = people/string
private let wiki = course/"wiki"
private let pages = course/"pages"
private let wikiPage = wiki/string
private let page = pages/string

class CookiesViewController: UIViewController, Destination {
    static func visit(with parameters: (String, String)) throws -> UIViewController {
        return UIViewController()
    }
}

extension Router {
    public static let teacher = Router(
        // Course view controller
        Route(course,       to: CourseViewController.self),
        
        // Assignments
        Route(assignments,  to: AssignmentsTableViewController.self),
        
        // People
        Route(people,       to: PeopleViewController.self),
        Route(person,       to: PersonDetailViewController.self),
        
        // Pages
        Route(pages,        to: PagesTableViewController.self),
        Route(wiki,         to: PagesTableViewController.self),
        Route(wikiPage,     to: PageDetailViewController.self),
        Route(page,         to: PageDetailViewController.self)
    )
}


extension Router {
    
    /**
     Uses the current environment's presenter to present the view controller registered for the given URL
     
     If there is not a route registered for `url`, presents a web browser view which navigates to `url`
     
     @param url The URL to route to
     @param source The view controller initiating the route
     @param animated duh.
     */
    public func route(to url: URL, from source: UIViewController, animated: Bool = true) {
        TEnv.try(in: source) {
            if let destination = try destination(for: url.path) {
                TEnv.current
                    .presenter
                    .present(destination, from: source, animated: animated)
            } else {
                let safari = SFSafariViewController(url: url)
                safari.modalPresentationStyle = .fullScreen
                source.present(safari, animated: true, completion: nil)
            }
        }
    }
}

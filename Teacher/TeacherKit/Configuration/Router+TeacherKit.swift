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

private let apiV1 = /?"api"/"v1"
private let courses = apiV1/?"courses"
private let course = courses/string

class CookiesViewController: UIViewController, Destination {
    static func visit(with parameters: (String, String)) throws -> UIViewController {
        return UIViewController()
    }
}

extension Router {
    public static let teacher = Router(
        Route(course, to: AssignmentsTableViewController.self)
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
                // TODO: SafariViewController?
            }
        }
    }
}

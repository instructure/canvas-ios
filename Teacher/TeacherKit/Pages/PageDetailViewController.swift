//
//  PageDetailViewController.swift
//  Teacher
//
//  Created by Derrick Hathaway on 2/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import PageKit
import TooLegit
import SixtySix

private func getToRouting(from vc: UIViewController, to url: URL) {
    TEnv.current.router.route(to: url, from: vc)
}

class PageDetailViewController: Page.DetailViewController, Destination {
    static func visit(with parameters: (String, String)) throws -> UIViewController {
        let (courseID, pageID) = parameters
        
        let deets = try PageDetailViewController(session: TEnv.current.session, contextID: .course(withID: courseID), url: pageID, route: getToRouting)
        
        return deets
    }
}

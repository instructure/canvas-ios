//
//  Student+AccessRemoved.swift
//  Parent
//
//  Created by Derrick Hathaway on 2/10/17.
//  Copyright © 2017 Instructure Inc. All rights reserved.
//

import UIKit
import Airwolf
import TooLegit


extension Student {
    static func refreshForAccessRemoved(session: Session, from currentViewController: UIViewController) {
        do {
            let refresher = try Student.observedStudentsRefresher(session)
            refresher.refreshingCompleted.observe { _ in
                Router.sharedInstance.routeToLoggedInViewController()
            }
            refresher.refresh(true)
        } catch let e as NSError {
            Router.sharedInstance.presentServerError(currentViewController, error: e)
        }
    }
}

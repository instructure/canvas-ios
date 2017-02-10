//
//  PagesTableViewController.swift
//  Teacher
//
//  Created by Derrick Hathaway on 2/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import SixtySix
import SoPersistent
import ReactiveSwift
import PageKit
import TooLegit

private func colorfulPageViewModel(session: Session, page: Page) -> ColorfulViewModel {
    
    let vm = ColorfulViewModel(features: page.frontPage ? [.token] : [])
    vm.title.value = page.title
    if page.frontPage {
        vm.tokenViewText.value = NSLocalizedString("Front Page", comment: "badge indicating front page")
    }
    vm.color <~ session.enrollmentsDataSource.color(for: page.contextID)
    
    return vm
}

private func route(from vc: UIViewController, to url: URL) {
    TEnv.current.router.route(to: url, from: vc)
}

class PagesTableViewController: Page.TableViewController, Destination {
    
    public static func visit(with courseID: (String)) throws -> UIViewController {
        let session = TEnv.current.session
        
        return try PagesTableViewController(session: session, contextID: .course(withID: courseID), viewModelFactory: colorfulPageViewModel, route: route)
    }
}

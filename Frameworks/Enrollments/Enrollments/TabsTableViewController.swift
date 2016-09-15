//
//  TabsTableViewController.swift
//
//
//  Created by Derrick Hathaway on 3/15/16.
//
//

import UIKit
import EnrollmentKit
import SoPersistent
import ReactiveCocoa
import TooLegit
import SoLazy
import SoPretty

extension ColorfulViewModel {
    
    init(session: Session, tab: Tab) {
        self.init(style: .Basic)
        
        title.value = tab.label
        icon.value = tab.icon

        color <~ session.enrollmentsDataSource.producer(tab.contextID).map { $0?.color ?? .prettyGray() }
    }
}

class TabsTableViewController: Tab.TableViewController {
    
    init(session: Session, contextID: ContextID) throws {
        super.init()
        let collection = try Tab.collection(session, contextID: contextID)
        let refresher = try Tab.refresher(session, contextID: contextID)
        prepare(collection, refresher: refresher) { tab in
            return ColorfulViewModel(session: session, tab: tab)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"Sorrrrry, no storyboards for me."
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tab = collection[indexPath]
        
        print("Navigate to URL: \(tab.url)")
    }
}

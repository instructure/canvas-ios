//
//  EntriesTableViewController.swift
//  Discussions
//
//  Created by Derrick Hathaway on 8/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import DiscussionKit
import SoPersistent
import TooLegit
import ReactiveCocoa
import EnrollmentKit

class EntriesTableViewController: DiscussionEntry.TableViewController {
    
    let session: Session
    
    init(session: Session, contextID: ContextID, topicID: String, parentEntryID: String? = nil) throws {
        self.session = session
        super.init()
        
        let c = try DiscussionEntry.collection(session, contextID: contextID, topicID: topicID, parentEntryID: parentEntryID)
        let r = try DiscussionEntry.refresher(session, contextID: contextID, topicID: topicID)
        let color = session.enrollmentsDataSource.producer(contextID).map { $0?.color ?? .prettyGray() }
        prepare(c, refresher: r) { (entry: DiscussionEntry) -> ColorfulViewModel in
            let vm = ColorfulViewModel(style: .Basic)
            vm.title.value = entry.message
            vm.color <~ color
            return vm
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let entry = collection[indexPath]
        
        let vc = try! EntriesTableViewController(session: session, contextID: entry.contextID, topicID: entry.topicID, parentEntryID: entry.id)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}


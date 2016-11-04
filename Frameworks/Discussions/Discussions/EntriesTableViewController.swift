
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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


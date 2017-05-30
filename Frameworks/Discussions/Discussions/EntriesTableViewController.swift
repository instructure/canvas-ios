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
import ReactiveSwift
import EnrollmentKit
import SoPersistent

class EntriesTableViewController: FetchedTableViewController<DiscussionEntry> {
    
    let session: Session
    
    init(session: Session, contextID: ContextID, topicID: String, parentEntryID: String? = nil) throws {
        self.session = session
        super.init()
        
        let c = try DiscussionEntry.collection(session, contextID: contextID, topicID: topicID, parentEntryID: parentEntryID)
        let r = try DiscussionEntry.refresher(session, contextID: contextID, topicID: topicID)
        let color = session.enrollmentsDataSource.color(for: contextID)
        prepare(c, refresher: r) { (entry: DiscussionEntry) -> ColorfulViewModel in
            let vm = ColorfulViewModel()
            vm.title.value = entry.message
            vm.color <~ color
            return vm
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = collection[indexPath]
        
        let vc = try! EntriesTableViewController(session: session, contextID: entry.contextID, topicID: entry.topicID, parentEntryID: entry.id)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}


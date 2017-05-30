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
import ReactiveSwift
import TooLegit
import SoLazy
import SoPretty

extension ColorfulViewModel {
    
    init(session: Session, tab: Tab) {
        self.init(features: .icon)
        
        title.value = tab.label
        icon.value = tab.icon

        color <~ session.enrollmentsDataSource.color(for: tab.contextID)
    }
}

class TabsTableViewController: FetchedTableViewController<Tab> {
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tab = collection[indexPath]
        
        print("Navigate to URL: \(tab.url)")
    }
}

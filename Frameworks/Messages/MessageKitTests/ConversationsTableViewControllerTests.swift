
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
    
    

import MessageKit
import SoAutomated

class ConversationsTableViewControllerTests: UnitTestCase {
    func testConversationTableViewController_refresh_addsRowsToTableView() {
        let context = Context(user: User1(), testCase: self)
        let tvc = prepareTableViewController(context)

        context.refresh(tableViewController: tvc, fixture: "conversations")

        XCTAssertEqual(2, tvc.tableView.numberOfRowsInSection(0))
    }

    private func prepareTableViewController(context: Context) -> Conversation.TableViewController {
        let tvc = Conversation.TableViewController()
        _ = tvc.view
        attempt {
            let collection = try Conversation.collection(context.user.session)
            let refresher = try Conversation.refresher(context.user.session)
            tvc.prepare(collection, refresher: refresher, viewModelFactory: ViewModelFactory.empty)
        }
        return tvc
    }
}

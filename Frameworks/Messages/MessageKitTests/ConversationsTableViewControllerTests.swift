//
//  ConversationsTableViewControllerTests.swift
//  Messages
//
//  Created by Nathan Armstrong on 7/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
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

//
//  DiscussionTopicDetailsTests.swift
//  Discussions
//
//  Created by Brandon Pluim on 4/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
@testable import DiscussionKit
import SoAutomated
import SoPersistent
import CoreData
import TooLegit
import Result

class DiscussionTopicDetailsTests: XCTestCase {
    let session = Session.bt
    var context: NSManagedObjectContext!
    var vc: DiscussionTopic.DetailViewController!
    var topic: DiscussionTopic!
    var observer: ManagedObjectObserver<DiscussionTopic>!
    let detailsFactory: DiscussionTopic->[SimpleDiscussionTopicDVM] = { return [SimpleDiscussionTopicDVM(title: $0.title)] }

    override func setUp() {
        super.setUp()
        context = try! session.discussionsManagedObjectContext()
        topic = DiscussionTopic.build(context, title: "DetailViewController Test")
        try! context.save()

        observer = try! DiscussionTopic.observer(session, courseID: "1861019", discussionTopicID: topic.id)

        let dataSource = try! DiscussionTopic.detailsTableViewDataSource(session, courseID: "1861019", discussionTopicID: topic.id, detailsFactory: detailsFactory)
        vc = DiscussionTopic.DetailViewController(dataSource: dataSource, refresher: nil)
        
        let _ = vc.view // trigger viewDidLoad
        vc.prepare(observer, refresher: nil, detailsFactory: detailsFactory)
    }

    func test_itDisplaysLocalDetails() {
        let tableView = vc.tableView
        let titleCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual("DetailViewController Test", titleCell?.textLabel?.text)
    }

    func test_itRefreshesDetails() {
        stub(session, "discussion_topic_details") { expectation in
            let refresher = try! DiscussionTopic.refresher(self.session, courseID: "1861019", discussionTopicID: self.topic.id)
            self.vc.refresher = refresher

            refresher.refreshingCompleted.observeNext(self.refreshCompletedWithExpectation(expectation))
            refresher.refresh(true)
        }

        context.refreshAllObjects()
        let titleCell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertNotEqual("DetailViewController Test", titleCell?.textLabel?.text)
        XCTAssertNotEqual("DetailViewController Test", topic.title)
    }
}

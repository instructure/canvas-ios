//
//  DisussionTopicDetailViewController.swift
//  Discussions
//
//  Created by Ben Kraus on 3/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import DiscussionKit
import TooLegit
import ReactiveCocoa
import SoLazy
import SoPersistent
import WhizzyWig

enum DiscussionTopicDetailCellViewModel: TableViewCellViewModel {
    case Title(String)
    case Message(NSURL, String)

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerClass(WhizzyWigTableViewCell.self, forCellReuseIdentifier: "MessageCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch self {
        case .Title(let title):
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell")!
            cell.textLabel?.text = title
            return cell
        case .Message(let baseURL, let message):
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! WhizzyWigTableViewCell
            cell.cellSizeUpdated = { _ in
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.whizzyWigView.loadHTMLString(message, baseURL: baseURL)
            return cell
        }
    }

    static func detailsForDiscussionTopic(baseURL: NSURL) -> (discussionTopic: DiscussionTopic) -> [DiscussionTopicDetailCellViewModel] {
        return { discussionTopic in
            return [
                .Title(discussionTopic.title),
                .Message(baseURL, discussionTopic.message)
            ]
        }
    }
}

extension DiscussionTopicDetailCellViewModel: Equatable {}
func ==(lhs: DiscussionTopicDetailCellViewModel, rhs: DiscussionTopicDetailCellViewModel) -> Bool {
    switch (lhs, rhs) {
    case let (.Title(leftTitle), .Title(rightTitle)):
        return leftTitle == rightTitle
    case let (.Message(leftURL, leftMessage), .Message(rightURL, rightMessage)):
        return leftURL == rightURL && leftMessage == rightMessage
    default:
        return false
    }
}

class DiscussionTopicDetailViewController: DiscussionTopic.DetailViewController {
    var disposable: Disposable?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func new(session: Session, courseID: String, discussionTopicID: String) throws -> DiscussionTopicDetailViewController {
        guard let me = UIStoryboard(name: "Discussions", bundle: nil).instantiateViewControllerWithIdentifier("DiscussionTopicDetail") as? DiscussionTopicDetailViewController else { ❨╯°□°❩╯⌢"blah, I hate life" }

        let observer = try DiscussionTopic.observer(session, courseID: courseID, discussionTopicID: discussionTopicID)
        let refresher = try DiscussionTopic.refresher(session, courseID: courseID, discussionTopicID: discussionTopicID)

        me.prepare(observer, refresher: refresher, detailsFactory: DiscussionTopicDetailCellViewModel.detailsForDiscussionTopic(session.baseURL))
        me.disposable = observer.signal.map { $0.1 }
            .observeOn(UIScheduler())
            .observeNext { discussionTopic in

        }

        return me
    }
}

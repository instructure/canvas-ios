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
    
    

import UIKit
import DiscussionKit
import TooLegit
import ReactiveSwift
import SoLazy
import SoPersistent
import WhizzyWig

enum DiscussionTopicDetailCellViewModel: TableViewCellViewModel {
    case title(String)
    case message(URL, String)

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(WhizzyWigTableViewCell.self, forCellReuseIdentifier: "MessageCell")
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .title(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell")!
            cell.textLabel?.text = title
            return cell
        case .message(let baseURL, let message):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! WhizzyWigTableViewCell
            cell.cellSizeUpdated = { _ in
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.whizzyWigView.loadHTMLString(message, baseURL: baseURL)
            return cell
        }
    }

    static func detailsForDiscussionTopic(_ baseURL: URL) -> (_ discussionTopic: DiscussionTopic) -> [DiscussionTopicDetailCellViewModel] {
        return { discussionTopic in
            return [
                .title(discussionTopic.title),
                .message(baseURL, discussionTopic.message)
            ]
        }
    }
}

extension DiscussionTopicDetailCellViewModel: Equatable {}
func ==(lhs: DiscussionTopicDetailCellViewModel, rhs: DiscussionTopicDetailCellViewModel) -> Bool {
    switch (lhs, rhs) {
    case let (.title(leftTitle), .title(rightTitle)):
        return leftTitle == rightTitle
    case let (.message(leftURL, leftMessage), .message(rightURL, rightMessage)):
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

    static func new(_ session: Session, courseID: String, discussionTopicID: String) throws -> DiscussionTopicDetailViewController {
        guard let me = UIStoryboard(name: "Discussions", bundle: nil).instantiateViewController(withIdentifier: "DiscussionTopicDetail") as? DiscussionTopicDetailViewController else { ❨╯°□°❩╯⌢"blah, I hate life" }

        let observer = try DiscussionTopic.observer(session, courseID: courseID, discussionTopicID: discussionTopicID)
        let refresher = try DiscussionTopic.refresher(session, courseID: courseID, discussionTopicID: discussionTopicID)

        me.prepare(observer, refresher: refresher, detailsFactory: DiscussionTopicDetailCellViewModel.detailsForDiscussionTopic(session.baseURL))
        me.disposable = observer.signal.map { $0.1 }
            .observe(on: UIScheduler())
            .observeValues { discussionTopic in

        }

        return me
    }
}

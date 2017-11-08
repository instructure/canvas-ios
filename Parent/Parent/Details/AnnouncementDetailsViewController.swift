//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation
import CanvasCore

import ReactiveSwift
import CanvasCore

import CanvasCore
import CanvasCore



private let TitleCellReuseIdentifier = "TitleCell"
private let AttachmentCellReuseIdentifier = "AttachmentCell"
private let MessageBodyCellReuseIdentifier = "MessageBodyCell"

enum AnnouncementDetailsCellViewModel: TableViewCellViewModel {
    case title(String)
    case attachment(String)
    case message(URL, String)

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(UINib(nibName: "DetailsInfoCell", bundle: nil), forCellReuseIdentifier: TitleCellReuseIdentifier)
        tableView.register(UINib(nibName: "DetailsAttachmentCell", bundle: nil), forCellReuseIdentifier: AttachmentCellReuseIdentifier)
        tableView.register(WhizzyWigTableViewCell.self, forCellReuseIdentifier: MessageBodyCellReuseIdentifier)
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .title(let title):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleCellReuseIdentifier) as? DetailsInfoCell else { ❨╯°□°❩╯⌢"Dude, you have the wrong type for this cell" }
            cell.titleLabel.text = title
            cell.setShowsSubmissionInfo(false)
            return cell
        case .attachment(let filename):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AttachmentCellReuseIdentifier) as? DetailsAttachmentCell else { ❨╯°□°❩╯⌢"Dude, you have the wrong type for this cell" }
            cell.filenameLabel.text = filename
            return cell
        case .message(let baseURL, let message):
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageBodyCellReuseIdentifier) as! WhizzyWigTableViewCell
            cell.cellSizeUpdated = { _ in
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.whizzyWigView.contentInsets = UIEdgeInsets(top: 1.0, left: 15.0, bottom: 1.0, right: 15.0)
            cell.whizzyWigView.loadHTMLString(message, baseURL: baseURL)
            return cell
        }
    }

    static func detailsForDiscussionTopic(_ baseURL: URL, discussionTopic: DiscussionTopic) -> [AnnouncementDetailsCellViewModel] {
        let attachmentInfo: AnnouncementDetailsCellViewModel? = discussionTopic
            .attachmentName
            .map(AnnouncementDetailsCellViewModel.attachment)
        
        return [
            .title(discussionTopic.title),
            attachmentInfo,
            .message(baseURL, discussionTopic.message)
        ].flatMap { $0 }
    }
}

extension AnnouncementDetailsCellViewModel: Equatable {}
func ==(lhs: AnnouncementDetailsCellViewModel, rhs: AnnouncementDetailsCellViewModel) -> Bool {
    switch (lhs, rhs) {
    case let (.title(leftTitle), .title(rightTitle)):
        return leftTitle == rightTitle
    case let (.message(leftURL, leftMessage), .message(rightURL, rightMessage)):
        return leftURL == rightURL && leftMessage == rightMessage
    default:
        return false
    }
}

class AnnouncementDetailsViewController: DiscussionTopic.DetailViewController {
    var disposable: Disposable?

    init(session: Session, studentID: String, courseID: String, announcementID: String) throws {
        super.init()
        let observer = try DiscussionTopic.observer(session, studentID: studentID, courseID: courseID, discussionTopicID: announcementID)
        let refresher = try DiscussionTopic.refresher(session, studentID: studentID, courseID: courseID, discussionTopicID: announcementID)

        prepare(observer, refresher: refresher) { AnnouncementDetailsCellViewModel.detailsForDiscussionTopic(session.baseURL, discussionTopic: $0) }
        disposable = observer.signal.map { $0.1 }
            .observe(on: UIScheduler())
            .observeValues { _ in
        }

        session.enrollmentsDataSource(withScope: studentID).producer(ContextID(id: courseID, context: .course)).observe(on: UIScheduler()).startWithValues { next in
            guard let course = next as? Course else { return }
            self.title = course.name
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

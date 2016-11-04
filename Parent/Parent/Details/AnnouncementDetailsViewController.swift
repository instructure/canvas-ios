
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
import DiscussionKit
import TooLegit
import ReactiveCocoa
import SoLazy
import SoPersistent
import WhizzyWig
import EnrollmentKit
import Airwolf
import FileKit

typealias Announcement = DiscussionTopic

private let TitleCellReuseIdentifier = "TitleCell"
private let AttachmentCellReuseIdentifier = "AttachmentCell"
private let MessageBodyCellReuseIdentifier = "MessageBodyCell"

enum AnnouncementDetailsCellViewModel: TableViewCellViewModel {
    case Title(String)
    case Attachment(String)
    case Message(NSURL, String)

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerNib(UINib(nibName: "DetailsInfoCell", bundle: nil), forCellReuseIdentifier: TitleCellReuseIdentifier)
        tableView.registerNib(UINib(nibName: "DetailsAttachmentCell", bundle: nil), forCellReuseIdentifier: AttachmentCellReuseIdentifier)
        tableView.registerClass(WhizzyWigTableViewCell.self, forCellReuseIdentifier: MessageBodyCellReuseIdentifier)
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch self {
        case .Title(let title):
            guard let cell = tableView.dequeueReusableCellWithIdentifier(TitleCellReuseIdentifier) as? DetailsInfoCell else { ❨╯°□°❩╯⌢"Dude, you have the wrong type for this cell" }
            cell.titleLabel.text = title
            cell.setShowsSubmissionInfo(false)
            return cell
        case .Attachment(let filename):
            guard let cell = tableView.dequeueReusableCellWithIdentifier(AttachmentCellReuseIdentifier) as? DetailsAttachmentCell else { ❨╯°□°❩╯⌢"Dude, you have the wrong type for this cell" }
            cell.filenameLabel.text = filename
            return cell
        case .Message(let baseURL, let message):
            let cell = tableView.dequeueReusableCellWithIdentifier(MessageBodyCellReuseIdentifier) as! WhizzyWigTableViewCell
            cell.cellSizeUpdated = { _ in
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.whizzyWigView.contentInsets = UIEdgeInsets(top: 1.0, left: 15.0, bottom: 1.0, right: 15.0)
            cell.whizzyWigView.loadHTMLString(message, baseURL: baseURL)
            return cell
        }
    }

    static func detailsForDiscussionTopic(baseURL: NSURL) -> (discussionTopic: DiscussionTopic) -> [AnnouncementDetailsCellViewModel] {
        return { discussionTopic in
            var attachmentInfo: AnnouncementDetailsCellViewModel? = nil
            if let attachmentID = discussionTopic.attachmentIDs.first {
                do {
                    if let file: File = try discussionTopic.managedObjectContext?.findOne(withPredicate: NSPredicate(format: "%K == %@", "id", attachmentID)) {
                        attachmentInfo = .Attachment(file.name)
                    }
                } catch {
                    print("error fetching file: \(error)")
                }
            }
            return [
                .Title(discussionTopic.title),
                attachmentInfo,
                .Message(baseURL, discussionTopic.message)
            ].flatMap { $0 }
        }
    }
}

extension AnnouncementDetailsCellViewModel: Equatable {}
func ==(lhs: AnnouncementDetailsCellViewModel, rhs: AnnouncementDetailsCellViewModel) -> Bool {
    switch (lhs, rhs) {
    case let (.Title(leftTitle), .Title(rightTitle)):
        return leftTitle == rightTitle
    case let (.Message(leftURL, leftMessage), .Message(rightURL, rightMessage)):
        return leftURL == rightURL && leftMessage == rightMessage
    default:
        return false
    }
}

class AnnouncementDetailsViewController: Announcement.DetailViewController {
    var disposable: Disposable?

    init(session: Session, studentID: String, courseID: String, announcementID: String) throws {
        super.init()
        let observer = try Announcement.observer(session, studentID: studentID, courseID: courseID, discussionTopicID: announcementID)
        let refresher = try DiscussionTopic.refresher(session, studentID: studentID, courseID: courseID, discussionTopicID: announcementID)

        prepare(observer, refresher: refresher, detailsFactory: AnnouncementDetailsCellViewModel.detailsForDiscussionTopic(session.baseURL))
        disposable = observer.signal.map { $0.1 }
            .observeOn(UIScheduler())
            .observeNext { _ in
        }

        session.enrollmentsDataSource(withScope: studentID).producer(ContextID(id: courseID, context: .Course)).observeOn(UIScheduler()).startWithNext { next in
            guard let course = next as? Course else { return }
            self.title = course.name
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

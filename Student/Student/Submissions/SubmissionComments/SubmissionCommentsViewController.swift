//
// Copyright (C) 2019-present Instructure, Inc.
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

import UIKit
import Core

class SubmissionCommentsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView?

    var currentUserID: String?
    var presenter: SubmissionCommentsPresenter?

    static func create(env: AppEnvironment = .shared, context: Context, assignmentID: String, userID: String, submissionID: String) -> SubmissionCommentsViewController {
        let controller = loadFromStoryboard()
        controller.presenter = SubmissionCommentsPresenter(env: env, view: controller, context: context, assignmentID: assignmentID, userID: userID, submissionID: submissionID)
        controller.currentUserID = env.currentSession?.userID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.transform = CGAffineTransform(scaleX: 1, y: -1)

        presenter?.viewIsReady()
    }
}

extension SubmissionCommentsViewController: SubmissionCommentsViewProtocol {
    func reload() {
        tableView?.reloadData()
    }
}

extension SubmissionCommentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.comments.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let comment = presenter?.comments[indexPath.row] else { return UITableViewCell() }

        if let attempt = comment.attempt {
            // TODO: display submission attachments
            let cell = UITableViewCell()
            cell.accessibilityLabel = "\(attempt)" // get rid of unused variable errors
            return cell
        }

        if comment.mediaURL != nil {
            let reuseID = currentUserID == comment.authorID ? "myMediaComment" : "theirMediaComment"
            let cell: SubmissionCommentMediaCell = tableView.dequeue(withID: reuseID, for: indexPath)
            cell.update(comment: comment, parent: self)
            return cell
        }

        let reuseID = currentUserID == comment.authorID ? "myComment" : "theirComment"
        let cell: SubmissionCommentTextCell = tableView.dequeue(withID: reuseID, for: indexPath)
        cell.update(comment: comment)
        return cell
    }
}

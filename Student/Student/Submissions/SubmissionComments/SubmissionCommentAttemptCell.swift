//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import Core

class SubmissionCommentAttemptCell: UITableViewCell {
    @IBOutlet weak var stackView: UIStackView?

    var onFileTap: ((Submission?, File?) -> Void)?

    func update(comment: SubmissionComment, submission: Submission?, onFileTap: @escaping (Submission?, File?) -> Void) {
        accessibilityIdentifier = "SubmissionComments.attemptCell.\(comment.id)"
        accessibilityLabel = String.localizedStringWithFormat(
            NSLocalizedString("On %@ %@ submitted the following", bundle: .student, comment: ""),
            DateFormatter.localizedString(from: comment.createdAt, dateStyle: .long, timeStyle: .short),
            comment.authorName
        )
        self.onFileTap = onFileTap

        for view in stackView?.arrangedSubviews ?? [] { view.removeFromSuperview() }
        if submission?.type == .online_upload, let files = submission?.attachments?.sorted(by: File.idCompare) {
            for file in files {
                let view = SubmissionCommentFileView.loadFromXib()
                view.update(file: file)
                view.onTap = { [weak self] in
                    self?.onFileTap?(submission, file)
                }
                stackView?.addArrangedSubview(view)
            }
        } else if let submission = submission, submission.submittedAt != nil {
            let view = SubmissionCommentFileView.loadFromXib()
            view.update(submission: submission)
            view.onTap = { [weak self] in
                self?.onFileTap?(submission, nil)
            }
            stackView?.addArrangedSubview(view)
        }
    }
}

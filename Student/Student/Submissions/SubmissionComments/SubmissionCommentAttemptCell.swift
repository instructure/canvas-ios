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

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .backgroundLightest
    }

    func update(comment: SubmissionComment, submission: Submission?, onFileTap: @escaping (Submission?, File?) -> Void) {
        guard let submission else { return } // it will never happen

        accessibilityIdentifier = "SubmissionComments.attemptCell.\(comment.id)"

        self.onFileTap = onFileTap

        for view in stackView?.arrangedSubviews ?? [] { view.removeFromSuperview() }
        if submission.type == .online_upload, let files = submission.attachments?.sorted(by: File.idCompare) {
            for file in files {
                let view = SubmissionCommentFileView.loadFromXib()
                view.update(comment: comment, file: file, submission: submission)
                view.onTap = { [weak self] in
                    self?.onFileTap?(submission, file)
                }
                stackView?.addArrangedSubview(view)
            }
        } else if submission.submittedAt != nil {
            let view = SubmissionCommentFileView.loadFromXib()
            view.update(comment: comment, submission: submission)
            view.onTap = { [weak self] in
                self?.onFileTap?(submission, nil)
            }
            stackView?.addArrangedSubview(view)
        }
    }
}

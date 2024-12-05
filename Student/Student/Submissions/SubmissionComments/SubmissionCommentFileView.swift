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

class SubmissionCommentFileView: UIControl {
    @IBOutlet weak var iconView: IconView?
    @IBOutlet weak var nameLabel: DynamicLabel?
    @IBOutlet weak var sizeLabel: DynamicLabel?

    var onTap: () -> Void = {}

    override func awakeFromNib() {
        backgroundColor = .backgroundLightest
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        layer.borderColor = UIColor.borderMedium.cgColor
        layer.borderWidth = 1.0
        iconView?.tintColor = Brand.shared.primary
        addTarget(self, action: #selector(didTapFile), for: .touchUpInside)
    }

    func update(file: File) {
        let id = file.id ?? ""
        accessibilityIdentifier = "SubmissionComments.fileView.\(id)"
        accessibilityLabel = String.localizedStringWithFormat(
            String(localized: "View file %@ %@", bundle: .student),
            file.displayName ?? "",
            file.size.humanReadableFileSize
        )
        iconView?.image = file.icon
        nameLabel?.text = file.displayName
        sizeLabel?.text = file.size.humanReadableFileSize
    }

    func update(submission: Submission) {
        accessibilityIdentifier = "SubmissionComments.attemptView.\(submission.attempt)"
        accessibilityLabel = String.localizedStringWithFormat(
            String(localized: "View submission attempt %d. %@", bundle: .student),
            submission.attempt,
            submission.attemptTitle ?? ""
        )
        iconView?.image = submission.attemptIcon
        nameLabel?.text = submission.attemptTitle
        sizeLabel?.text = submission.attemptSubtitle
    }

    @IBAction func didTapFile(_ sender: UIControl) {
        onTap()
    }
}

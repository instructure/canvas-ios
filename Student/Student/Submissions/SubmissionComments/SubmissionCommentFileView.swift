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

    // This method (and the whole class) is used only for files in attempts, not for files in simple comments
    func update(file: File, submission: Submission) {
        iconView?.image = file.icon
        nameLabel?.text = file.displayName
        sizeLabel?.text = file.size.humanReadableFileSize

        accessibilityIdentifier = "SubmissionComments.fileView.\(file.id ?? "")"
        accessibilityLabel = [
            String.localizedAttemptNumber(submission.attempt),
            submission.attemptAccessibilityDescription,
            file.displayName,
            file.size.humanReadableFileSize
        ].joined(separator: ", ")
        accessibilityHint = String(localized: "Double tap to view file", bundle: .core)
    }

    func update(submission: Submission) {
        iconView?.image = submission.attemptIcon
        nameLabel?.text = submission.attemptTitle
        sizeLabel?.text = submission.attemptSubtitle

        accessibilityIdentifier = "SubmissionComments.attemptView.\(submission.attempt)"
        accessibilityLabel = [
            String.localizedAttemptNumber(submission.attempt),
            submission.attemptAccessibilityDescription
        ].joined(separator: ", ")
        accessibilityHint = String(localized: "Double tap to view attempt", bundle: .core)
    }

    @IBAction func didTapFile(_ sender: UIControl) {
        onTap()
    }
}

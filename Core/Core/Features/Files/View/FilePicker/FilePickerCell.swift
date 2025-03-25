//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

protocol FilePickerCellDelegate: AnyObject {
    func removeFile(_ file: File)
}

class FilePickerCell: UITableViewCell {
    @IBOutlet weak var nameLabel: DynamicLabel!
    @IBOutlet weak var subtitleLabel: DynamicLabel!
    @IBOutlet weak var errorIcon: IconView!
    @IBOutlet weak var removeButton: DynamicButton!

    weak var delegate: FilePickerCellDelegate?

    var file: File? {
        didSet {
            backgroundColor = .backgroundLightest
            nameLabel.text = file?.localFileURL?.lastPathComponent
            if let filename = file?.filename {
                removeButton.accessibilityLabel = String.localizedStringWithFormat(String(localized: "Remove %@", bundle: .core), filename)
            }
            if file?.uploadError != nil {
                errorIcon.isHidden = false
                subtitleLabel.text = String(localized: "Failed upload", bundle: .core)
                subtitleLabel.textColor = .textDanger
            } else {
                errorIcon.isHidden = true
                subtitleLabel.text = file?.size.humanReadableFileSize
                subtitleLabel.textColor = .textDark
            }
        }
    }

    @IBAction func removeTapped() {
        guard let file = file else { return }
        delegate?.removeFile(file)
    }
}

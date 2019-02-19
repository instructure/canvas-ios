//
// Copyright (C) 2018-present Instructure, Inc.
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
import UIKit

class FilePickerCell: UITableViewCell {
    var file: FileViewModel? {
        didSet {
            nameLabel.text = file?.url.lastPathComponent
            if file?.error != nil {
                isUserInteractionEnabled = true
                errorIcon.isHidden = false
                subtitleLabel.text = NSLocalizedString("Failed upload", bundle: .core, value: "", comment: "")
                subtitleLabel.textColor = .named(.textDanger)
            } else {
                isUserInteractionEnabled = false
                errorIcon.isHidden = true
                subtitleLabel.text = file?.size.humanReadableFileSize
                subtitleLabel.textColor = UIColor.named(.ash)
            }
        }
    }

    @IBOutlet weak var nameLabel: DynamicLabel!
    @IBOutlet weak var subtitleLabel: DynamicLabel!
    @IBOutlet weak var errorIcon: IconView!
}

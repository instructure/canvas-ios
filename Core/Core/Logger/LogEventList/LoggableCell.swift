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

extension Loggable {
    var icon: UIImage {
        switch type {
        case .log, .error:
            return UIImage.icon(.empty, .solid)
        }
    }

    var iconTintColor: UIColor {
        switch type {
        case .error:
            return .named(.backgroundDanger)
        case .log:
            return .named(.backgroundSuccess)
        }
    }
}

class LoggableCell: UITableViewCell {
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    var loggable: Loggable? {
        didSet {
            typeImageView.image = loggable?.icon
            typeImageView.tintColor = loggable?.iconTintColor
            messageLabel.text = loggable?.message
            timestampLabel.text = loggable.flatMap { LoggableCell.dateFormatter.string(from: $0.timestamp) }
        }
    }
}

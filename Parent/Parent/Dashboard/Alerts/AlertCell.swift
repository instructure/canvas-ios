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
    
    

import UIKit



import CanvasCore


class AlertCell: UITableViewCell {

    static let iconImageDiameter: CGFloat = 36.0
    static let iconImageSubtractor: CGFloat = 15.0

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!

    var highlightColor = UIColor.white
    var alert: Alert? = nil
    var session : Session? = nil

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        self.accessibilityCustomActions = [UIAccessibilityCustomAction(name: "Dismiss", target: self, selector: #selector(AlertCell.dismiss(_:)))]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = selected ? highlightColor : UIColor.white
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        contentView.backgroundColor = highlighted ? highlightColor : UIColor.white
    }

    func dismiss(_ obj: Any?) {
        guard let _alert = alert, let _session = session else { return }

        _alert.dismiss(_session)
    }

}

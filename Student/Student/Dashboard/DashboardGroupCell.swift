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

import UIKit

class DashboardGroupCell: UICollectionViewCell {
    @IBOutlet weak var leftColorView: UIView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var termLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        roundCornersAndDropShadow()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        groupNameLabel.text = ""
        courseNameLabel.text = ""
        termLabel.text = ""
        leftColorView.backgroundColor = .clear
    }

    // TODO: Switch to using a "bubble" image with rounded corners
    // and drop shadow so that is is more efficient
    func roundCornersAndDropShadow() {
        contentView.layer.cornerRadius = 4.0
        contentView.layer.borderWidth = 1.0 / UIScreen.main.nativeScale
        contentView.layer.borderColor = UIColor(white: 0.89, alpha: 1.0).cgColor
        contentView.clipsToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
    }

    func configure(with model: DashboardViewModel.Group) {
        groupNameLabel.text = model.groupName
        courseNameLabel.text = model.courseName ?? ""
        courseNameLabel.textColor = model.color ?? .black
        termLabel.text = model.term ?? ""
        leftColorView.backgroundColor = model.color ?? .black
    }

}

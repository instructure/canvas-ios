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

class AllCoursesCourseCell: UICollectionViewCell {
    @IBOutlet var topView: UIView!
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var abbrevationLabel: UILabel!

    var optionsCallback: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()

        // Round the corners and drop shadow here so
        // that it will adjust as the cell size changes
        roundCornersAndDropShadow()
    }

    // TODO: Switch to using a "bubble" image with rounded corners
    // and drop shadow so that is is more efficient
    func roundCornersAndDropShadow() {
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.clipsToBounds = true

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.75
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        titleLabel.textColor = UIColor.black
        abbrevationLabel.text = ""
    }

    func configure(with model: AllCoursesViewModel.Course) {
        titleLabel.text = model.title
        titleLabel.textColor = model.color
        abbrevationLabel.text = model.abbreviation
        topView.backgroundColor = model.color
    }

    @IBAction func optionsButtonTapped(_ sender: Any) {
        optionsCallback?()
    }
}

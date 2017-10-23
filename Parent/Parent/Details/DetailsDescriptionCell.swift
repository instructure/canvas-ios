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

class DetailsDescriptionCell: WhizzyWigTableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        whizzyWigView.backgroundColor = UIColor.clear
        whizzyWigView.contentFontColor = UIColor(r: 102.0, g: 102.0, b: 102.0)
        whizzyWigView.contentInsets = UIEdgeInsets(top: 14.0, left: 51.0, bottom: 14.0, right: 15.0)

        setupIcon()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupIcon() {
        let icon = UIImage(named: "icon_document")
        let iconImageView = UIImageView(image: icon)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(r: 180.0, g: 180.0, b: 180.0)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)

        let views = ["iconImageView": iconImageView, "whizzyWigView": whizzyWigView]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-padding-[iconImageView(iconHeight)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["padding": 10, "iconHeight": 28], views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-padding-[iconImageView(iconWidth)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["padding": 12, "iconWidth": 31], views: views)

        contentView.addConstraints(verticalConstraints)
        contentView.addConstraints(horizontalConstraints)
    }

}

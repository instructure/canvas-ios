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

class CourseCardCell: UICollectionViewCell {
    @IBOutlet weak var abbrevationLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: UIView!

    var optionsCallback: (() -> Void)?
    let optionsCircle = CALayer()

    func update(_ course: Course?, hideColorOverlay: Bool, optionsCallback: @escaping () -> Void) {
        let id = course?.id ?? ""
        cardView.accessibilityIdentifier = "CourseCardCell.\(id)"
        cardView.accessibilityLabel = course?.name
        optionsButton.accessibilityIdentifier = "CourseCardCell.\(id).optionsButton"
        optionsButton.accessibilityLabel = String.localizedStringWithFormat(
            NSLocalizedString("Open %@ user preferences", bundle: .core, comment: ""),
            course?.name ?? ""
        )
        accessibilityElements = [ cardView as Any, optionsButton as Any ]

        let color = course?.color.ensureContrast(against: .named(.backgroundLightest))
        imageView.load(url: course?.imageDownloadURL)
        titleLabel.text = course?.name
        titleLabel.textColor = color
        abbrevationLabel.text = course?.courseCode
        topView.backgroundColor = color
        if course?.showColorOverlay(hideOverlaySetting: hideColorOverlay) == true {
            imageView.alpha = 0.4
            optionsCircle.removeFromSuperlayer()
        } else {
            imageView.alpha = 1
            optionsCircle.frame = CGRect(x: 8, y: 8, width: optionsButton.bounds.width - 16, height: optionsButton.bounds.height - 16)
            optionsCircle.backgroundColor = color?.cgColor
            optionsCircle.cornerRadius = optionsCircle.frame.width / 2
            optionsButton.layer.insertSublayer(optionsCircle, below: optionsButton.imageView?.layer)
        }
        self.optionsCallback = optionsCallback
    }

    @IBAction func showOptions() {
        optionsCallback?()
    }
}

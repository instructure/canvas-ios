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
import Core

class DashboardGroupCell: UICollectionViewCell {
    @IBOutlet weak var leftColorView: UIView?
    @IBOutlet weak var groupNameLabel: UILabel?
    @IBOutlet weak var courseNameLabel: UILabel?
    @IBOutlet weak var termLabel: UILabel?

    var group: Group? = nil {
        didSet {
            _accessibilityElements = nil
        }
    }

    private var _accessibilityElements: [Any]?
    override var accessibilityElements: [Any]? {
        set {
            _accessibilityElements = newValue
        }

        get {
            guard let group = group else {
                return nil
            }

            // Return the accessibility elements if we've already created them.
            if let elements = _accessibilityElements {
                return elements
            }

            var elements = [UIAccessibilityElement]()
            let cardElement = UIAccessibilityElement(accessibilityContainer: self)
            cardElement.accessibilityLabel = group.name
            cardElement.accessibilityFrameInContainerSpace = bounds
            elements.append(cardElement)

            _accessibilityElements = elements

            return _accessibilityElements
        }

    }

    func configure(with model: Group) {
        let color = model.color.ensureContrast(against: .named(.white))
        group = model
        groupNameLabel?.text = model.name
        courseNameLabel?.text = nil //model.courseName
        courseNameLabel?.textColor = color
        termLabel?.text = nil
        leftColorView?.backgroundColor = color
    }
}

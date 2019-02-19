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
    @IBOutlet weak var leftColorView: UIView?
    @IBOutlet weak var groupNameLabel: UILabel?
    @IBOutlet weak var courseNameLabel: UILabel?
    @IBOutlet weak var termLabel: UILabel?

    var group: DashboardViewModel.Group? = nil {
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
            cardElement.accessibilityLabel = group.groupName
            cardElement.accessibilityFrameInContainerSpace = bounds
            elements.append(cardElement)

            _accessibilityElements = elements

            return _accessibilityElements
        }

    }

    func configure(with model: DashboardViewModel.Group) {
        let color = model.color.ensureContrast(against: .named(.white))
        group = model
        groupNameLabel?.text = model.groupName
        courseNameLabel?.text = model.courseName
        courseNameLabel?.textColor = color
        termLabel?.text = model.term
        leftColorView?.backgroundColor = color
    }
}

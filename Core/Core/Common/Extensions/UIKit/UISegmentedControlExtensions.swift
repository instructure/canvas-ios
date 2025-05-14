//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public extension UISegmentedControl {
    static func updateFontAppearance() {
        Self.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular13)], for: .normal)
        Self.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.scaledNamedFont(.bold13)], for: .selected)
    }

    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    func removeBorders() {
        setBackgroundImage(
            imageWithColor(color: UIColor.clear),
            for: .normal,
            barMetrics: .default
        )
        setBackgroundImage(
            imageWithColor(color: UIColor.clear),
            for: .selected,
            barMetrics: .default
        )
        setDividerImage(
            imageWithColor(color: UIColor.clear),
            forLeftSegmentState: .normal,
            rightSegmentState: .normal,
            barMetrics: .default
        )
    }

    func setFontStyle(_ selectionColor: UIColor?) {

        let normalStyle: [NSAttributedString.Key: Any] = [
            .font: UIFont.scaledNamedFont(.regular14),
            .foregroundColor: UIColor.textDark
        ]

        let selectedStyle: [NSAttributedString.Key: Any] = [
            .font: UIFont.scaledNamedFont(.bold14),
            .foregroundColor: selectionColor ?? .textDark
        ]

        setTitleTextAttributes(normalStyle, for: .normal)
        setTitleTextAttributes(selectedStyle, for: .selected)
    }

    func addUnderlineForSelectedSegment(_ selectionColor: UIColor?) {
        if let existingView = viewWithTag(1) {
            existingView.frame.size.width = self.bounds.size.width / CGFloat(self.numberOfSegments)
            existingView.frame.origin.x = selectedSegmentOriginX
            return
        }
        removeBorders()
        setFontStyle(selectionColor)
        let underlineWidth: CGFloat = bounds.size.width / CGFloat(numberOfSegments)
        let underlineHeight: CGFloat = 1.5
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = bounds.size.height - 0.5
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = selectionColor ?? .backgroundInfo
        underline.tag = 1
        addSubview(underline)
    }

    func changeUnderlinePosition() {
        guard let underline = viewWithTag(1) else { return }
        UIView.animate(withDuration: 0.3) {
            underline.frame.origin.x = self.selectedSegmentOriginX
        }
    }

    private var selectedSegmentOriginX: Double {
        (frame.width / CGFloat(numberOfSegments)) * CGFloat(selectedSegmentIndex)
    }
}

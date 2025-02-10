//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

public class TitleSubtitleView: UIView {
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var subtitleLabel: UILabel!

    public var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }

    public var subtitle: String? {
        get { return subtitleLabel.text }
        set { subtitleLabel.text = newValue }
    }

    override public var accessibilityLabel: String? {
        get {
            guard var label = titleLabel.text else { return nil }

            if let subtitle = subtitleLabel.text, subtitle != "" {
                label += ", \(subtitle)"
            }
            return label
        }
        set { _ = newValue }
    }

    public static func create() -> Self {
        let view = loadFromXib()
        view.titleLabel.text = ""
        view.subtitleLabel.text = ""
        view.titleLabel.font = .scaledNamedFont(.semibold16)
        view.subtitleLabel.font = .scaledNamedFont(.regular12)
        view.titleLabel.accessibilityElementsHidden = true
        view.subtitleLabel.accessibilityElementsHidden = true
        view.accessibilityTraits = [.header]
        return view
    }

    public func recreate() -> TitleSubtitleView {
        let copy = TitleSubtitleView.create()
        copy.title = title
        copy.subtitle = subtitle
        return copy
    }

    public override func tintColorDidChange() {
        let title = (superview?.superview as? UINavigationBar)?.titleTextAttributes?[.foregroundColor] as? UIColor
        let color = title ?? tintColor
        titleLabel.textColor = color
        subtitleLabel.textColor = color == .textDarkest ? .textDark : color
    }
}

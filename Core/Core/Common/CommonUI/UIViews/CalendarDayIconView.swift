//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public class CalendarDayIconView: UIView {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var iconView: UIImageView!

    public static func create(date: Date = Date(), tintColor: UIColor = .textLightest.variantForLightMode) -> CalendarDayIconView {
        let view = loadFromXib()
        view.setDate(date)
        view.tintColor = tintColor
        return view
    }

    static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }()

    public func setDate(_ date: Date) {
        dayLabel.text = CalendarDayIconView.formatter.string(from: date)
    }

    public override var tintColor: UIColor! {
        get { return iconView.tintColor }
        set {
            dayLabel.textColor = newValue
            iconView.tintColor = newValue
        }
    }
}

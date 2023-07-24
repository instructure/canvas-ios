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

public extension UIBarButtonItem {

    static func updateFontAppearance() {
        let attributes = [NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular17)]
        let appearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        appearance.setTitleTextAttributes(attributes, for: .normal)
    }

    static func back(target: Any, action: Selector) -> UIBarButtonItem {
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        let backImage = UIImage(systemName: "chevron.backward", withConfiguration: config)
        let barButton = UIBarButtonItem(image: backImage,
                                        landscapeImagePhone: backImage,
                                        style: .plain,
                                        target: target,
                                        action: action)
        barButton.imageInsets = .init(top: 0, left: -7.5, bottom: 0, right: 0)
        barButton.landscapeImagePhoneInsets = .init(top: 0, left: -8, bottom: 0, right: 0)
        return barButton
    }
}

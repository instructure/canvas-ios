//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Foundation

public extension UIMenu {

    /**
     This method traverses the menu tree and collects all `UIAction` elements into a single array.
     */
    var allActions: [UIAction] {
        children.reduce(into: [] as [UIAction]) { result, element in
            if let action = element as? UIAction {
                result.append(action)
            } else if let menu = element as? UIMenu {
                result.append(contentsOf: menu.allActions)
            }
        }
    }

    func firstAction(with identifier: UIAction.Identifier) -> UIAction? {
        allActions.first { $0.identifier == identifier }
    }
}

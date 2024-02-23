//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

extension UIMenu {

    static func modulePublishOnNavBar() -> UIMenu {
        let publish = [
            ModulePublishItem(title: String(localized: "Publish All Modules And Items"), action: .publish),
            ModulePublishItem(title: String(localized: "Publish Modules Only"), action: .publish),
        ]
        let unpublish = [
            ModulePublishItem(title: String(localized: "Unpublish All Modules And Items"), action: .unpublish),
        ]

        return UIMenu(children: [publish.menu, unpublish.menu])
    }

    static func modulePublishOnModule() -> UIMenu {
        let publish = [
            ModulePublishItem(title: String(localized: "Publish Module And All Items"), action: .publish),
            ModulePublishItem(title: String(localized: "Publish Module Only"), action: .publish),
        ]
        let unpublish = [
            ModulePublishItem(title: String(localized: "Unpublish Module And All Items"), action: .unpublish),
        ]
        return UIMenu(children: [publish.menu, unpublish.menu])
    }

    static func modulePublishOnItem(action: ModulePublishItem.Action) -> UIMenu {
        let item = (action == .publish) ? ModulePublishItem(title: String(localized: "Publish"), action: .publish)
                                        : ModulePublishItem(title: String(localized: "Unpublish"), action: .unpublish)

        return [item].menu
    }
}

private extension Array where Element == ModulePublishItem {

    var menu: UIMenu {
        UIMenu(options: .displayInline,
               children: map { UIAction(title: $0.title, image: $0.icon, handler: { _ in }) })
    }
}

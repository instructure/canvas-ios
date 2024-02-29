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

import UIKit

extension UIMenu {

    static func modulesPublishMenu(
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) -> UIMenu {
        UIMenu(children: [
            UIMenu(modulePublishItems: ModulePublishMenu.Modules.publish, host: host, router: router),
            UIMenu(modulePublishItems: ModulePublishMenu.Modules.unpublish, host: host, router: router),
        ])
    }

    static func modulePublishMenu(
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) -> UIMenu {
        UIMenu(children: [
            UIMenu(modulePublishItems: ModulePublishMenu.Module.publish, host: host, router: router),
            UIMenu(modulePublishItems: ModulePublishMenu.Module.unpublish, host: host, router: router),
        ])
    }

    static func moduleItemPublishMenu(
        action: ModulePublishItem.Action,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) -> UIMenu {
        let item: ModulePublishItem

        if action == .publish {
            item = ModulePublishMenu.Item.publish[0]
        } else {
            item = ModulePublishMenu.Item.unpublish[0]
        }

        return UIMenu(modulePublishItems: [item], host: host, router: router)
    }
}

extension Array where Element == UIAccessibilityCustomAction {

    static func modulePublishA11yActions(
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) -> [UIAccessibilityCustomAction] {
        [
            .init(modulePublishItem: ModulePublishMenu.Module.publish[0], host: host, router: router),
            .init(modulePublishItem: ModulePublishMenu.Module.publish[1], host: host, router: router),
            .init(modulePublishItem: ModulePublishMenu.Module.unpublish[0], host: host, router: router),
        ]
    }

    static func moduleItemPublishA11yActions(
        action: ModulePublishItem.Action,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) -> [UIAccessibilityCustomAction] {
        let item: ModulePublishItem

        if action == .publish {
            item = ModulePublishMenu.Item.publish[0]
        } else {
            item = ModulePublishMenu.Item.unpublish[0]
        }

        return [.init(modulePublishItem: item, host: host, router: router)]
    }
}

// MARK: - Private Helpers

private struct ModulePublishMenu {

    struct Modules {
        static let publish = [
            ModulePublishItem(title: String(localized: "Publish All Modules And Items"),
                              confirmMessage: String(localized: "This will make all modules and items visible to students."),
                              action: .publish),
            ModulePublishItem(title: String(localized: "Publish Modules Only"),
                              confirmMessage: String(localized: "This will make only the modules visible to students."),
                              action: .publish),
        ]
        static let unpublish = [
            ModulePublishItem(title: String(localized: "Unpublish All Modules And Items"),
                              confirmMessage: String(localized: "This will make all modules and items invisible to students."),
                              action: .unpublish),
        ]
    }

    struct Module {
        static let publish = [
            ModulePublishItem(title: String(localized: "Publish Module And All Items"),
                              confirmMessage: String(localized: "This will make the module and all items visible to students."),
                              action: .publish),
            ModulePublishItem(title: String(localized: "Publish Module Only"),
                              confirmMessage: String(localized: "This will make only the module visible to students."),
                              action: .publish),
        ]
        static let unpublish = [
            ModulePublishItem(title: String(localized: "Unpublish Module And All Items"),
                              confirmMessage: String(localized: "This will make the module and all items invisible to students."),
                              action: .unpublish),
        ]
    }

    struct Item {
        static let publish = [
            ModulePublishItem(title: String(localized: "Publish"),
                              confirmMessage: String(localized: "This will make only this item visible to students."),
                              action: .publish),
        ]
        static let unpublish = [
            ModulePublishItem(title: String(localized: "Unpublish"),
                              confirmMessage: String(localized: "This will make only this item invisible to students."),
                              action: .unpublish),
        ]
    }
}

private extension UIMenu {

    convenience init(
        modulePublishItems: [ModulePublishItem],
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) {
        self.init(
            options: .displayInline,
            children: modulePublishItems.map { UIAction(modulePublishItem: $0, host: host, router: router) }
        )
    }
}

private extension UIAction {

    convenience init(
        modulePublishItem: ModulePublishItem,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) {
        self.init(
            title: modulePublishItem.title,
            image: modulePublishItem.icon,
            handler: { [weak host] _ in
                guard let host else { return }
                let alert = UIAlertController(modulePublishItem: modulePublishItem)
                router.show(alert, from: host, options: .modal())
            }
       )
    }
}

private extension UIAlertController {

    convenience init(modulePublishItem: ModulePublishItem) {
        self.init(title: modulePublishItem.action.alertTitle,
                   message: modulePublishItem.confirmMessage,
                   preferredStyle: .alert)
        addAction(AlertAction(modulePublishItem.action.alertConfirmation, style: .default) { _ in
        })
        addAction(AlertAction(String(localized: "Cancel"), style: .cancel))
    }
}

private extension ModulePublishItem.Action {

    var alertTitle: String {
        switch self {
        case .publish: return String(localized: "Publish?")
        case .unpublish: return String(localized: "Unpublish?")
        }
    }

    var alertConfirmation: String {
        switch self {
        case .publish: return String(localized: "Publish")
        case .unpublish: return String(localized: "Unpublish")
        }
    }
}

private extension UIAccessibilityCustomAction {

    convenience init(
        modulePublishItem: ModulePublishItem,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) {
        self.init(name: modulePublishItem.title) { [weak host] _ in
            guard let host else { return false }
            let alert = UIAlertController(modulePublishItem: modulePublishItem)
            router.show(alert, from: host, options: .modal())
            return true
        }
    }
}

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

struct ModulePublishMenu {

    static var NavBar = (
        publish: [
            ModulePublishItem(title: String(localized: "Publish All Modules And Items"),
                              confirmMessage: String(localized: "This will make all modules and items visible to students."),
                              action: .publish),
            ModulePublishItem(title: String(localized: "Publish Modules Only"),
                              confirmMessage: String(localized: "This will make only the modules visible to students."),
                              action: .publish),
        ],
        unpublish: [
            ModulePublishItem(title: String(localized: "Unpublish All Modules And Items"),
                              confirmMessage: String(localized: "This will make all modules and items invisible to students."),
                              action: .unpublish),
        ]
    )

    static var Module = (
        publish: [
            ModulePublishItem(title: String(localized: "Publish Module And All Items"),
                              confirmMessage: String(localized: "This will make the module and all items visible to students."),
                              action: .publish),
            ModulePublishItem(title: String(localized: "Publish Module Only"),
                              confirmMessage: String(localized: "This will make only the module visible to students."),
                              action: .publish),
        ],
        unpublish: [
            ModulePublishItem(title: String(localized: "Unpublish Module And All Items"),
                              confirmMessage: String(localized: "This will make the module and all items invisible to students."),
                              action: .unpublish),
        ]
    )

    static var Item = (
        publish: [
            ModulePublishItem(title: String(localized: "Publish"),
                              confirmMessage: String(localized: "This will make only this item visible to students."),
                              action: .publish),
        ],
        unpublish: [
            ModulePublishItem(title: String(localized: "Unpublish"),
                              confirmMessage: String(localized: "This will make only this item invisible to students."),
                              action: .unpublish),
        ]
    )
}

extension UIMenu {

    static func modulePublishOnNavBar(
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) -> UIMenu {
        UIMenu(children: [
            UIMenu(modulePublishItems: ModulePublishMenu.NavBar.publish, host: host, router: router, actionDidPerform: {}),
            UIMenu(modulePublishItems: ModulePublishMenu.NavBar.unpublish, host: host, router: router, actionDidPerform: {}),
        ])
    }

    static func modulePublishOnModule(
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) -> UIMenu {
        UIMenu(children: [
            UIMenu(modulePublishItems: ModulePublishMenu.Module.publish, host: host, router: router, actionDidPerform: {}),
            UIMenu(modulePublishItems: ModulePublishMenu.Module.unpublish, host: host, router: router, actionDidPerform: {}),
        ])
    }

    static func modulePublishOnItem(
        action: PutModuleItemPublishRequest.Action,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping () -> Void
    ) -> UIMenu {
        let item: ModulePublishItem

        if action == .publish {
            item = ModulePublishMenu.Item.publish[0]
        } else {
            item = ModulePublishMenu.Item.unpublish[0]
        }

        return UIMenu(modulePublishItems: [item], host: host, router: router, actionDidPerform: actionDidPerform)
    }
}

private extension UIMenu {

    convenience init(
        modulePublishItems: [ModulePublishItem],
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping () -> Void
    ) {
        self.init(
            options: .displayInline,
            children: modulePublishItems.map {
                UIAction(
                    modulePublishItem: $0,
                    host: host,
                    router: router,
                    actionDidPerform: actionDidPerform
                )
            }
        )
    }
}

private extension UIAction {

    convenience init(
        modulePublishItem: ModulePublishItem,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping () -> Void
    ) {
        self.init(
            title: modulePublishItem.title,
            image: modulePublishItem.icon,
            handler: { [weak host] _ in
                guard let host else { return }
                let alert = UIAlertController(
                    modulePublishItem: modulePublishItem,
                    actionDidPerform: actionDidPerform
                )
                router.show(alert, from: host, options: .modal())
            }
       )
    }
}

private extension UIAlertController {

    convenience init(
        modulePublishItem: ModulePublishItem,
        actionDidPerform: @escaping () -> Void
    ) {
        self.init(title: modulePublishItem.action.alertTitle,
                   message: modulePublishItem.confirmMessage,
                   preferredStyle: .alert)
        addAction(AlertAction(modulePublishItem.action.alertConfirmation, style: .default) { _ in
            actionDidPerform()
        })
        addAction(AlertAction(String(localized: "Cancel"), style: .cancel))
    }
}

private extension PutModuleItemPublishRequest.Action {

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

// MARK: - Accessibility Support

extension Array where Element == UIAccessibilityCustomAction {

    static func modulePublishActionsOnModule(
        host: UIViewController,
        router: Router = AppEnvironment.shared.router
    ) -> [UIAccessibilityCustomAction] {
        [
            .init(modulePublishItem: ModulePublishMenu.Module.publish[0],
                  host: host,
                  router: router,
                  actionDidPerform: {}),
            .init(modulePublishItem: ModulePublishMenu.Module.publish[1],
                  host: host,
                  router: router,
                  actionDidPerform: {}),
            .init(modulePublishItem: ModulePublishMenu.Module.unpublish[0],
                  host: host,
                  router: router,
                  actionDidPerform: {}),
        ]
    }

    static func modulePublishActionsOnItem(
        action: PutModuleItemPublishRequest.Action,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping () -> Void
    ) -> [UIAccessibilityCustomAction] {
        let item: ModulePublishItem

        if action == .publish {
            item = ModulePublishMenu.Item.publish[0]
        } else {
            item = ModulePublishMenu.Item.unpublish[0]
        }

        return [.init(modulePublishItem: item, host: host, router: router, actionDidPerform: actionDidPerform)]
    }
}

private extension UIAccessibilityCustomAction {

    convenience init(
        modulePublishItem: ModulePublishItem,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping () -> Void
    ) {
        self.init(name: modulePublishItem.title) { [weak host] _ in
            guard let host else { return false }
            let alert = UIAlertController(
                modulePublishItem: modulePublishItem,
                actionDidPerform: actionDidPerform
            )
            router.show(alert, from: host, options: .modal())
            return true
        }
    }
}

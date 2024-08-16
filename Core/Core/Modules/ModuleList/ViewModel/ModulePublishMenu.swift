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

// MARK: - Menu building

extension UIMenu {

    static func makePublishAllModulesMenu(
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping (ModulePublishAction) -> Void
    ) -> UIMenu {
        let model = ModulePublishMenuModel.allModules
        return UIMenu(modulePublishMenuModel: model, host: host, router: router, actionDidPerform: actionDidPerform)
    }

    static func makePublishModuleMenu(
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping (ModulePublishAction) -> Void
    ) -> UIMenu {
        let model = ModulePublishMenuModel.module
        return UIMenu(modulePublishMenuModel: model, host: host, router: router, actionDidPerform: actionDidPerform)
    }

    static func makePublishModuleItemMenu(
        action: ModulePublishAction,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping () -> Void
    ) -> UIMenu {
        let model: [[ModulePublishItem]]

        switch action {
        case .publish:
            model = ModulePublishMenuModel.itemPublish
        case .unpublish:
            model = ModulePublishMenuModel.itemUnpublish
        }

        return UIMenu(modulePublishMenuModel: model, host: host, router: router) { _ in
            actionDidPerform()
        }
    }
}

extension Array where Element == UIAccessibilityCustomAction {

    static func makePublishModuleA11yActions(
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping (ModulePublishAction) -> Void
    ) -> [UIAccessibilityCustomAction] {
        makeActions(modulePublishMenuModel: ModulePublishMenuModel.module, host: host, router: router, actionDidPerform: actionDidPerform)
    }

    static func makePublishModuleItemA11yActions(
        action: ModulePublishAction,
        host: UIViewController,
        router: Router = AppEnvironment.shared.router,
        actionDidPerform: @escaping () -> Void
    ) -> [UIAccessibilityCustomAction] {
        let model: [[ModulePublishItem]]

        switch action {
        case .publish:
            model = ModulePublishMenuModel.itemPublish
        case .unpublish:
            model = ModulePublishMenuModel.itemUnpublish
        }

        return makeActions(modulePublishMenuModel: model, host: host, router: router) { _ in
            actionDidPerform()
        }
    }
}

// MARK: - Menu models

private enum ModulePublishMenuModel {
    static let allModules = [
        [
            AllModules.publishWithItems,
            AllModules.publishWithoutItems,
        ],
        [
            AllModules.unpublishWithItems,
        ],
    ]

    static let module = [
        [
            Module.publishWithItems,
            Module.publishWithoutItems,
        ],
        [
            Module.unpublishWithItems,
        ],
    ]

    static let itemPublish = [
        [Item.publish]
    ]

    static let itemUnpublish = [
        [Item.unpublish]
    ]

    enum AllModules {
        static let publishWithItems = ModulePublishItem(
            title: String(localized: "Publish All Modules And Items", bundle: .core),
            confirmMessage: String(localized: "This will make all modules and items visible to students.", bundle: .core),
            accessibilityIdentifier: "PublishAllModulesAndItems",
            action: .publish(.modulesAndItems)
        )

        static let publishWithoutItems = ModulePublishItem(
            title: String(localized: "Publish Modules Only", bundle: .core),
            confirmMessage: String(localized: "This will make only the modules visible to students.", bundle: .core),
            accessibilityIdentifier: "PublishModulesOnly",
            action: .publish(.onlyModules)
        )

        static let unpublishWithItems = ModulePublishItem(
            title: String(localized: "Unpublish All Modules And Items", bundle: .core),
            confirmMessage: String(localized: "This will make all modules and items invisible to students.", bundle: .core),
            accessibilityIdentifier: "UnpublishAllModulesAndItems",
            action: .unpublish(.modulesAndItems)
        )
    }

    enum Module {
        static let publishWithItems = ModulePublishItem(
            title: String(localized: "Publish Module And All Items", bundle: .core),
            confirmMessage: String(localized: "This will make the module and all items visible to students.", bundle: .core),
            accessibilityIdentifier: "PublishModulesAndAllItems",
            action: .publish(.modulesAndItems)
        )

        static let publishWithoutItems = ModulePublishItem(
            title: String(localized: "Publish Module Only", bundle: .core),
            confirmMessage: String(localized: "This will make only the module visible to students.", bundle: .core),
            accessibilityIdentifier: "PublishModuleOnly",
            action: .publish(.onlyModules)
        )

        static let unpublishWithItems = ModulePublishItem(
            title: String(localized: "Unpublish Module And All Items", bundle: .core),
            confirmMessage: String(localized: "This will make the module and all items invisible to students.", bundle: .core),
            accessibilityIdentifier: "UnpublishModuleAndAllItems",
            action: .unpublish(.modulesAndItems)
        )
    }

    enum Item {
        static let publish = ModulePublishItem(
            title: String(localized: "Publish", bundle: .core),
            confirmMessage: String(localized: "This will make only this item visible to students.", bundle: .core),
            accessibilityIdentifier: "Publish",
            action: .publish
        )

        static let unpublish = ModulePublishItem(
            title: String(localized: "Unpublish", bundle: .core),
            confirmMessage: String(localized: "This will make only this item invisible to students.", bundle: .core),
            accessibilityIdentifier: "Unpublish",
            action: .unpublish
        )
    }
}

// MARK: - Private UIMenu helpers

private extension UIMenu {
    convenience init(
        modulePublishMenuModel: [[ModulePublishItem]],
        host: UIViewController,
        router: Router,
        actionDidPerform: @escaping (ModulePublishAction) -> Void
    ) {
        let children: [UIMenuElement]
        if modulePublishMenuModel.count == 1 {
            children = modulePublishMenuModel[0].map(makeAction)
        } else {
            children = modulePublishMenuModel.map { section in
                UIMenu(options: .displayInline, children: section.map(makeAction))
            }
        }

        self.init(children: children)

        func makeAction(with item: ModulePublishItem) -> UIAction {
            UIAction(modulePublishItem: item, host: host, router: router) {
                actionDidPerform(item.action)
            }
        }
    }
}

private extension UIAction {

    convenience init(
        modulePublishItem: ModulePublishItem,
        host: UIViewController,
        router: Router,
        actionDidPerform: @escaping () -> Void
    ) {
        self.init(
            title: modulePublishItem.title,
            image: modulePublishItem.icon,
            handler: { [weak host] _ in
                guard let host else { return }
                let alert = UIAlertController(modulePublishItem: modulePublishItem, actionDidPerform: actionDidPerform)
                router.show(alert, from: host, options: .modal())
            }
        )
        self.accessibilityIdentifier = modulePublishItem.accessibilityIdentifier
    }
}

// MARK: - Private Accessibility helpers

private extension Array where Element == UIAccessibilityCustomAction {

    static func makeActions(
        modulePublishMenuModel: [[ModulePublishItem]],
        host: UIViewController,
        router: Router,
        actionDidPerform: @escaping (ModulePublishAction) -> Void
    ) -> [UIAccessibilityCustomAction] {
        modulePublishMenuModel.flatMap { $0 }.map { item in
            UIAccessibilityCustomAction(modulePublishItem: item, host: host, router: router) {
                actionDidPerform(item.action)
            }
        }
    }
}

private extension UIAccessibilityCustomAction {

    convenience init(
        modulePublishItem: ModulePublishItem,
        host: UIViewController,
        router: Router,
        actionDidPerform: @escaping () -> Void
    ) {
        self.init(name: modulePublishItem.title) { [weak host] _ in
            guard let host else { return false }
            let alert = UIAlertController(modulePublishItem: modulePublishItem, actionDidPerform: actionDidPerform)
            router.show(alert, from: host, options: .modal())
            return true
        }
    }
}

// MARK: - Private Alert Helpers

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
        addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel))
    }
}

private extension ModulePublishAction {

    var alertTitle: String {
        switch self {
        case .publish: return String(localized: "Publish?", bundle: .core)
        case .unpublish: return String(localized: "Unpublish?", bundle: .core)
        }
    }

    var alertConfirmation: String {
        switch self {
        case .publish: return String(localized: "Publish", bundle: .core)
        case .unpublish: return String(localized: "Unpublish", bundle: .core)
        }
    }
}

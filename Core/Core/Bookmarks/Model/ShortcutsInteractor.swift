//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
import UIKit

public protocol ShortcutsInteractor {

    /**
     This method extracts shortcut launch information if there's any from the launch options dictionary
     then sets up a task to present the shortcut's route after the app setup is complete.
     */
    func applicationDidLaunch(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?)

    /**
     When a shortcut item is received the shortcut's route is presented unless there's already a shortcut
     route received via the applicationDidLaunch method. In this later case the presentation will be handled
     by this applicationDidLaunch method and this method will do nothing.
     */
    func applicationDidReceiveShortcut(_ shortcut: UIApplicationShortcutItem)

    /**
     Synchronizes bookmarks from CoreData as app icon shortcut items.
     */
    func applicationWillResignActive(_ application: UIApplication)

    /**
     When the user logs in we should fetch bookmarks to be converted to shortcuts later when the app resigns active state.
     */
    func userDidLogin(application: UIApplication)

    /**
     Upon logout shortcut items should be cleared.
     */
    func userDidLogout(application: UIApplication)
}

class ShortcutsInteractorLive: ShortcutsInteractor {
    private let environment: AppEnvironment
    private var shortcutURL: URL?

    public init(environment: AppEnvironment) {
        self.environment = environment
    }

    public func applicationDidLaunch(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let shortcut = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem,
              let url = shortcut.bookmarkURL
        else { return }

        shortcutURL = url
        environment.performAfterStartup { [weak self] in
            self?.handleDeferredShortcut()
        }
    }

    public func applicationDidReceiveShortcut(_ shortcut: UIApplicationShortcutItem) {
        guard let url = shortcut.bookmarkURL,
              let sourceView = environment.topViewController,
              !isShortcutURLHandlingDeferred()
        else { return }

        environment.router.route(to: url,
                                 from: sourceView,
                                 options: .modal(embedInNav: true,
                                                 addDoneButton: true,
                                                 animated: false))
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        let scope = Scope(predicate: .all,
                          order: [
                            NSSortDescriptor(key: #keyPath(BookmarkItem.position),
                                             ascending: true),
                          ])
        let useCase = LocalUseCase<BookmarkItem>(scope: scope)
        var subscription: AnyCancellable?
        subscription = ReactiveStore(useCase: useCase)
            .getEntitiesFromDatabase()
            .mapArray { UIApplicationShortcutItem(bookmark: $0) }
            .sink(receiveCompletion: { _ in
                subscription?.cancel()
                subscription = nil
            }, receiveValue: { shortcuts in
                application.shortcutItems = shortcuts
            })
    }

    public func userDidLogin(application: UIApplication) {
        var subscription: AnyCancellable?
        subscription = ReactiveStore(useCase: GetBookmarks())
            .getEntities()
            .sink(receiveCompletion: { _ in
                subscription?.cancel()
                subscription = nil
            }, receiveValue: { _ in })
    }

    public func userDidLogout(application: UIApplication) {
        application.shortcutItems = nil
        shortcutURL = nil
    }

    /**
     - returns: True if the app was cold launched from a bookmark quick action
     and the url handling is deferred until the app is completely started.
     */
    private func isShortcutURLHandlingDeferred() -> Bool {
        shortcutURL != nil
    }

    private func handleDeferredShortcut() {
        guard let url = shortcutURL,
              let sourceView = environment.topViewController
        else { return }

        shortcutURL = nil
        environment.router.route(to: url,
                                 from: sourceView,
                                 options: .modal(embedInNav: true,
                                                 addDoneButton: true,
                                                 animated: true))
    }
}

extension UIApplicationShortcutItem {

    var bookmarkURL: URL? {
        if let urlString = userInfo?["bookmarkURL"] as? String,
           let url = URL(string: urlString) {
            return url
        } else {
            return nil
        }
    }

    convenience init(bookmark: BookmarkItem) {
        self.init(type: "bookmark",
                  localizedTitle: bookmark.name,
                  localizedSubtitle: nil,
                  icon: UIApplicationShortcutIcon(templateImageName: "bookmarkLine"),
                  userInfo: ["bookmarkURL": bookmark.url as NSSecureCoding])
    }
}

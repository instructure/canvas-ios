//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import Combine
import CoreData
import SwiftUI
import WidgetKit

public protocol AppEnvironmentDelegate {
    var environment: AppEnvironment { get }
}

open class AppEnvironment {
    public enum App: String {
        case parent, student, teacher, horizon
    }

    public internal(set) lazy var uploadManager = UploadManager(
        env: self,
        identifier: "com.instructure.core.file-uploads"
    )

    public var app: App?
    public var api: API
    public var database: NSPersistentContainer
    public var globalDatabase: NSPersistentContainer = NSPersistentContainer.shared
    public var logger: LoggerProtocol
    public var router: Router
    public var currentSession: LoginSession?
    public var pendoID: String?
    public var userDefaults: SessionDefaults? {
        didSet {
            k5.sessionDefaults = userDefaults
        }
    }
    public var lastLoginAccount: APIAccountResult?
    public let k5 = K5State()
    public weak var loginDelegate: LoginDelegate?
    public weak var window: UIWindow?
    open var isTest: Bool { false }
    private var subscriptions = Set<AnyCancellable>()

    public init() {
        self.database = globalDatabase
        self.api = API()
        self.router = Router(routes: []) { _, _, _, _ in }
        self.logger = Logger.shared
    }

    open var root: AppEnvironment { self }

    /**
     - parameters:
        - isSilent: If this parameter is true then the method won't trigger a widget refresh
     and also won't update the last logged in user data. Useful if we want to do something in
     the background with a user logged into the app while it's not the currently active user.
     */
    public func userDidLogin(session: LoginSession, isSilent: Bool = false) {
        // If the interactor was re-created using the global database
        // we have to reset and re-initialize it to use the session's DB
        OfflineModeAssembly.reset()
        database = NSPersistentContainer.create(session: session)
        OfflineModeAssembly.make()
        api = API(session)
        currentSession = session
        currentSession?.migrateSavedAnnotatedPDFs()
        userDefaults = SessionDefaults(sessionID: session.uniqueID)
        router.courseTabUrlInteractor?.clearEnabledTabs()
        router.courseTabUrlInteractor?.setupTabSubscription()

        if isSilent {
            return
        }

        refreshWidgets()
        saveAccount(for: session)

        Just(())
            .receive(on: RunLoop.main)
            .flatMap { CoreWebView.deleteAllCookies() }
            .sink {
                CoreWebView.refreshKeepAliveCookies()
            }
            .store(in: &subscriptions)
    }

    public func userDidLogout(session: LoginSession) {
        guard session == currentSession else { return }
        OfflineModeAssembly.reset()
        database = globalDatabase
        api = API()
        k5.userDidLogout()
        currentSession = nil
        userDefaults = nil
        router.courseTabUrlInteractor?.cancelTabSubscription()
        refreshWidgets()
        deleteUserData(session: session)
    }

    private func deleteUserData(session: LoginSession) {
        CourseSyncCleanupInteractor(session: session)
            .clean()
            .sink()
            .store(in: &subscriptions)
    }

    public static var shared = AppEnvironment()

    public func subscribe<U>(_ useCase: U, _ callback: @escaping Store<U>.EventHandler = { }) -> Store<U> where U: UseCase {
        return Store(env: self, useCase: useCase, eventHandler: callback)
    }

    public func subscribe<Model>(scope: Scope, _ callback: @escaping Store<LocalUseCase<Model>>.EventHandler = {}) -> Store<LocalUseCase<Model>> {
        let useCase = LocalUseCase<Model>(scope: scope)
        return subscribe(useCase, callback)
    }

    public var topViewController: UIViewController? {
        let locateTopViewController: () -> UIViewController? = {
            var controller = self.window?.rootViewController
            while controller?.presentedViewController != nil {
                controller = controller?.presentedViewController
            }
            return controller
        }

        if Thread.isMainThread {
            return locateTopViewController()
        } else {
            return DispatchQueue.main.sync { locateTopViewController() }
        }
    }

    private var startupIsCompleted = false
    private var startupTasks: [() -> Void] = []

    public func performAfterStartup(task: @escaping () -> Void) {
        guard !startupIsCompleted else { return task() }
        startupTasks.append(task)
    }

    public func startupDidComplete() {
        guard !startupIsCompleted else { return }
        startupIsCompleted = true
        for task in startupTasks { task() }
        startupTasks.removeAll()
    }

    public var errorHandler: ((Error, UIViewController?) -> Void)?

    public func reportError(_ error: Error?, from controller: UIViewController? = nil) {
        guard let error = error else { return }
        errorHandler?(error, controller ?? topViewController)
    }

    public func refreshWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    public func saveAccount(for session: LoginSession) {
        guard let lastLoginAccount = lastLoginAccount, session.baseURL.host == lastLoginAccount.domain else { return }
        let data = try? APIJSONEncoder().encode(lastLoginAccount)
        UserDefaults.standard.set(data, forKey: "lastLoginAccount")
    }

    public var apiHost: String? {
        currentSession?.baseURL.host()
    }
}

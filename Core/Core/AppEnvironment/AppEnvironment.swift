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
import CoreData

public protocol AppEnvironmentDelegate {
    var environment: AppEnvironment { get }
}

open class AppEnvironment {
    public enum App {
        case parent, student, teacher
    }

    public var app: App?
    public var api: API
    public var database: NSPersistentContainer
    public var globalDatabase: NSPersistentContainer = NSPersistentContainer.shared
    public var logger: LoggerProtocol
    public var router: Router
    public var currentSession: LoginSession?
    public var pageViewLogger: PageViewEventViewControllerLoggingProtocol = PresenterPageViewLogger()
    public var userDefaults: SessionDefaults?
    public weak var loginDelegate: LoginDelegate?
    public weak var window: UIWindow?

    public init() {
        self.database = globalDatabase
        self.api = URLSessionAPI()
        self.router = Router(routes: []) { _, _, _ in }
        self.logger = Logger.shared
    }

    public func userDidLogin(session: LoginSession) {
        database = NSPersistentContainer.create(session: session)
        api = URLSessionAPI(loginSession: session, baseURL: session.baseURL)
        currentSession = session
        userDefaults = SessionDefaults(sessionID: session.uniqueID)
        Logger.shared.database = database
    }

    public func userDidLogout(session: LoginSession) {
        guard session == currentSession else { return }
        database = globalDatabase
        api = URLSessionAPI()
        currentSession = nil
        userDefaults = nil
        Logger.shared.database = database
    }

    public static var shared = AppEnvironment()

    public func subscribe<U>(_ useCase: U, _ callback: @escaping Store<U>.EventHandler) -> Store<U> where U: UseCase {
        return Store(env: self, useCase: useCase, eventHandler: callback)
    }

    public func subscribe<Model>(scope: Scope, _ callback: @escaping Store<LocalUseCase<Model>>.EventHandler) -> Store<LocalUseCase<Model>> {
        let useCase = LocalUseCase<Model>(scope: scope)
        return subscribe(useCase, callback)
    }

    public var topViewController: UIViewController? {
        var controller = window?.rootViewController
        while controller?.presentedViewController != nil {
            controller = controller?.presentedViewController
        }
        return controller
    }
}

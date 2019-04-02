//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

public protocol AppEnvironmentDelegate {
    var environment: AppEnvironment { get }
}

open class AppEnvironment {
    public var api: API
    public var database: NSPersistentContainer
    public var globalDatabase: NSPersistentContainer = NSPersistentContainer.create()
    public var logger: LoggerProtocol
    public let queue = OperationQueue()
    public var router: RouterProtocol
    public var currentSession: KeychainEntry?

    public init() {
        self.database = globalDatabase
        self.api = URLSessionAPI()
        self.router = Router(routes: [])
        self.logger = Logger.shared
    }

    public func userDidLogin(session: KeychainEntry) {
        database = NSPersistentContainer.create(session: session)
        api = URLSessionAPI(accessToken: session.accessToken, actAsUserID: session.actAsUserID, baseURL: session.baseURL)
        currentSession = session
        Logger.shared.database = database
    }

    public func userDidLogout(session: KeychainEntry) {
        guard session == currentSession else { return }
        database.destroy()
        database = globalDatabase
        api = URLSessionAPI()
        currentSession = nil
        Logger.shared.database = database
    }

    public static let shared = AppEnvironment()

    public func subscribe<T: Scoped>(_ scoped: T.Type, _ name: T.ScopeKeys) -> FetchedResultsController<T> {
        let scope = T.scope(forName: name)
        return database.fetchedResultsController(predicate: scope.predicate, sortDescriptors: scope.order, sectionNameKeyPath: scope.sectionNameKeyPath)
    }

    public func subscribe<U>(_ useCase: U, _ callback: @escaping Store<U>.EventHandler) -> Store<U> where U: UseCase {
        return Store(env: self, useCase: useCase, eventHandler: callback)
    }

    public func subscribe<Model>(scope: Scope, _ callback: @escaping Store<LocalUseCase<Model>>.EventHandler) -> Store<LocalUseCase<Model>> {
        let useCase = LocalUseCase<Model>(scope: scope)
        return subscribe(useCase, callback)
    }
}

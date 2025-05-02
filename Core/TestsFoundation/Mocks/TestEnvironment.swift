//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Core
import CoreData
import XCTest

public class TestEnvironment: AppEnvironment {
    public var mockStore = false
    override open var isTest: Bool { true }

    override public init() {
        super.init()
        let session = LoginSession.make()
        self.api = API(session)
        self.database = singleSharedTestDatabase
        self.globalDatabase = singleSharedTestDatabase
        self.router = TestRouter()
        self.logger = TestLogger()
        self.currentSession = session
        self.userDefaults = SessionDefaults(sessionID: session.uniqueID)
    }

    override public func subscribe<U>(_ useCase: U, _ callback: @escaping Store<U>.EventHandler = { }) -> Store<U> where U: UseCase {
        if mockStore {
            return TestStore(env: self, useCase: useCase, eventHandler: callback)
        }
        return super.subscribe(useCase, callback)
    }
}

public class TestStore<U: UseCase>: Store<U> {
    public let refreshExpectation = XCTestExpectation(description: "Refresh")
    override public func refresh(force: Bool = false, callback: ((U.Response?) -> Void)? = nil) -> Self {
        refreshExpectation.fulfill()
        return self
    }

    public let exhaustExpectation = XCTestExpectation(description: "Exhaust")
    override public func exhaust(force: Bool = true, while condition: @escaping (U.Response) -> Bool = { _ in true }) -> Self {
        exhaustExpectation.fulfill()
        return self
    }

    public let getNextPageExpectation = XCTestExpectation(description: "Next Page")
    override public func getNextPage(_ callback: ((U.Response?) -> Void)? = nil) {
        getNextPageExpectation.fulfill()
    }

    public var overridePending: Bool?
    public override var pending: Bool {
        overridePending ?? super.pending
    }

    public var overrideRequested: Bool?
    public override var requested: Bool {
        overrideRequested ?? super.requested
    }
}

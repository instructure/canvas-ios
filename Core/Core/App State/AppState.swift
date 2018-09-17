//
//  AppState.swift
//  Core
//
//  Created by Layne Moseley on 8/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

public protocol AppStateDelegate {
    var appState: AppState { get }
}

public class AppState {
    public let router: Router
    public var api: API
    public let database: Persistence

    public init(router: Router, api: API, database: Persistence) {
        self.router = router
        self.api = api
        self.database = database
    }
}

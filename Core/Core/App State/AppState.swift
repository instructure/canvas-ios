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

    public init(router: Router) {
        self.router = router
    }
}

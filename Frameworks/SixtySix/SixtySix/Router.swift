//
//  Router.swift
//  SixtySix
//
//  Created by Derrick Hathaway on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

public struct Router {
    let routes: [Route]
    
    public init(_ routes: Route...) {
        self.routes = routes
    }
    
    public func destination(for path: String) throws -> UIViewController? {
        return try routes.lazy
            .flatMap { try $0.follow(path) }
            .first
    }
}

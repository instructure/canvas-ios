//
//  Router.swift
//  Core
//
//  Created by Layne Moseley on 8/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import UIKit

public typealias RouteFactory = () -> UIViewController?

// A route is a place you can go in the app
// Each app defines it's own routes by adding Routes to the Router
public struct Route {
    public let path: String
    public let factory: RouteFactory
    public init(_ path: String, factory: @escaping RouteFactory) {
        self.path = path
        self.factory = factory
    }
}

public struct RouteOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let modal = RouteOptions(rawValue: 1)
}

// The Router stores all routes that can be routed to in the app
public class Router {
    private var routes = [String: Route]()
    
    public init() {}
    
    public var count: Int {
        return routes.count
    }
    
    public func addRoute(_ route: Route) {
        routes[route.path] = route
    }
    
    public func addRoute(_ path: String, factory: @escaping RouteFactory) {
        let route = Route(path, factory: factory)
        addRoute(route)
    }
    
    public func routeForPath(_ path: String) -> Route? {
        return routes[path]
    }
    
    public func route(to: String, from: UIViewController) {
        guard let route = routeForPath(to) else { return }
        guard let destination = route.factory() else { return }
        from.show(destination, sender: nil)
    }
}

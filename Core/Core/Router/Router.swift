//
//  Router.swift
//  Core
//
//  Created by Layne Moseley on 8/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import UIKit

public typealias RouteFactory = (RouteInfo) -> UIViewController?

public struct RouteInfo {
    public let params: [String:String]
    public let query: [String:String]
}

// A route is a place you can go in the app
// Each app defines it's own routes by adding Routes to the Router
public struct Route {
    public let path: String
    public let pathRegExp: NSRegularExpression
    public let factory: RouteFactory
    public init(_ path: String, pathRegExp: NSRegularExpression, factory: @escaping RouteFactory) {
        self.path = path
        self.pathRegExp = pathRegExp
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
    private var routes = [NSRegularExpression: Route]()

    public init() {}

    public var count: Int {
        return routes.count
    }

    public func addRoute(_ route: Route) {
        routes[route.pathRegExp] = route
    }

    public func addRoute(_ path: String, factory: @escaping RouteFactory) {
        guard let regexp = pathToRegexp(path) else { return }
        let route = Route(path, pathRegExp:regexp, factory: factory)
        addRoute(route)
    }
    
    public func routeForPath(_ path: String) -> (Route, RouteInfo)? {
        for (regexp, route) in routes {
            guard let match = regexp.firstMatch(in: path, range: NSMakeRange(0, path.count)) else { continue }
            let params = extractParamsFromPath(path, match:match, routePath: route.path)
            let query = extractQueryParamsFromPath(path)
            return (route, RouteInfo(params: params, query: query))
        }
        return nil
    }

    public func route(to: String, from: UIViewController) {
        guard let (route, routeInfo) = routeForPath(to) else { return }
        guard let destination = route.factory(routeInfo) else { return }
        from.show(destination, sender: nil)
    }
}

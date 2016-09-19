//
//  Route.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/12/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import URITemplate

class Route {
    enum Presentation {
        case Master
        case Detail
        case Modal(UIModalPresentationStyle)
    }
    
    let presentation: Presentation
    let template: URITemplate
    let factory: (RouteAction, Session, parameters: [String: String]) throws -> UIViewController?
    
    init(_ presentation: Presentation, path: URITemplate, factory: (RouteAction, Session, [String: String]) throws -> UIViewController?) {
        self.presentation = presentation
        self.template = path
        self.factory = factory
    }
    
    func constructViewController(route: RouteAction, session: Session, url: NSURL) throws -> UIViewController? {
        guard let apiPath = url.path else { return nil }
        let path = apiPath.stringByReplacingOccurrencesOfString("/api/v1", withString: "") // remove the api prefix
        guard let parameters = template.extract(path) else { return nil }
        
        return try factory(route, session, parameters: parameters)
    }
}

typealias RouteAction = (UIViewController, NSURL) throws -> ()
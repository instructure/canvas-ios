
//
// Copyright (C) 2016-present Instructure, Inc.
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
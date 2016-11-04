
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
    
    

import Foundation
import TechDebt
import SoLazy
import Marshal
import TooLegit
import SoPersistent
import PageKit

extension Router {
    
    func addCanvasRoutes(handleError: (NSError)->()) {
        func currentSession()->Session { return TheKeymaster.currentClient.authSession }

        func addContextRoute(contexts: [ContextID.Context], subPath: String, file: String = #file, line: UInt = #line, handler: (ContextID, [String: AnyObject]) throws -> UIViewController?) {
            for context in contexts {
                addRoute("/\(context.pathComponent)/:contextID"/subPath) { parameters, _ in
                    do {
                        let contextID: String = try parameters.stringID("contextID")
                        return try handler(ContextID(id: contextID, context: context), parameters)
                    } catch let e as Error {
                        handleError(NSError(jsonError: e, file: file, line: line))
                    } catch let e as NSError {
                        handleError(e)
                    }
                    return nil
                }
            }
        }
        
        let route: (UIViewController, NSURL)->() = { [weak self] viewController, url in
            self?.routeFromController(viewController, toURL: url)
        }
        

        addContextRoute([.Course, .Group], subPath: "tabs") { contextID, _ in
            return try TabsTableViewController(session: currentSession(), contextID: contextID, route: route)
        }
        
        addContextRoute([.Course], subPath: "assignments") { contextID, _ in
            return try AssignmentsTableViewController(session: currentSession(), courseID: contextID.id, route: route)
        }
        
        addContextRoute([.Course], subPath: "grades") { contextID, _ in
            return try GradesTableViewController(session: currentSession(), courseID: contextID.id, route: route)
        }

        let pagesListViewModelFactory: (Session, Page) -> ColorfulViewModel = { session, page in
            Page.colorfulPageViewModel(session: session, page: page)
        }

        let pagesListFactory: (ContextID, [String: AnyObject]) throws -> UIViewController? = { contextID, _ in
            let controller = try Page.TableViewController(session: currentSession(), contextID: contextID, viewModelFactory: pagesListViewModelFactory, route: route)
            controller.cbi_canBecomeMaster = true
            return controller
        }

        addContextRoute([.Course, .Group], subPath: "pages", handler: pagesListFactory)
        addContextRoute([.Course, .Group], subPath: "wiki", handler: pagesListFactory)
        addContextRoute([.Course, .Group], subPath: "pages/:url") { contextID, parameters in
            let url = parameters["url"] as! String
            return try Page.DetailViewController(session: currentSession(), contextID: contextID, url: url, route: route)
        }
        addContextRoute([.Course, .Group], subPath: "front_page") { contextID, _ in
            return try Page.FrontPageDetailViewController(session: currentSession(), contextID: contextID, route: route)
        }
        addContextRoute([.Course, .Group], subPath: "pages_home") { contextID, _ in
            return try PagesHomeViewController(session: currentSession(), contextID: contextID, listViewModelFactory: pagesListViewModelFactory, route: route)
        }
    }
}
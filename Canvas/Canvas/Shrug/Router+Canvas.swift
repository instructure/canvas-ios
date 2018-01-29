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
import CanvasCore
import Marshal
import CanvasKeymaster
import CanvasCore

var currentSession: Session {
    return CanvasKeymaster.the().currentClient.authSession
}

extension Router {
    
    func addCanvasRoutes(_ handleError: @escaping (NSError)->()) {
        func addContextRoute(_ contexts: [ContextID.Context], subPath: String, file: String = #file, line: UInt = #line, handler: @escaping (ContextID, [String: Any]) throws -> UIViewController?) {
            for context in contexts {
                addRoute("/\(context.pathComponent)/:contextID"/subPath) { parameters, _ in
                    do {
                        let contextID: String = try parameters!.stringID("contextID")
                        return try handler(ContextID(id: contextID, context: context), parameters!)
                    } catch let e as MarshalError {
                        handleError(NSError(jsonError: e, parsingObjectOfType: String.self, file: file, line: line))
                    } catch let e as NSError {
                        handleError(e)
                    }
                    return nil
                }
            }
        }
        
        let route: (UIViewController, URL)->() = { [weak self] viewController, url in
            let _ = self?.route(from: viewController, to: url)
        }
        

        addContextRoute([.course, .group], subPath: "tabs") { contextID, _ in
            return try TabsTableViewController(session: currentSession, contextID: contextID, route: route)
        }
        
        addContextRoute([.course], subPath: "assignments") { contextID, _ in
            return try AssignmentsTableViewController(session: currentSession, courseID: contextID.id, route: route)
        }
        
        addContextRoute([.course], subPath: "grades") { contextID, _ in
            return try GradesTableViewController(session: currentSession, courseID: contextID.id, route: route)
        }

        // Activity Stream
        addContextRoute([.course, .group], subPath: "activity_stream") { contextID, _ in
            return try ActivityStreamTableViewController(session: currentSession, context: contextID, route: route)
        }

        // Pages
        let pagesListViewModelFactory: (Session, Page) -> ColorfulViewModel = { session, page in
            Page.colorfulPageViewModel(session: session, page: page)
        }

        let pagesListFactory: (ContextID, [String: Any]) throws -> UIViewController? = { contextID, _ in
            let controller = try Page.TableViewController(session: currentSession, contextID: contextID, viewModelFactory: pagesListViewModelFactory, route: route)
            return controller
        }
        addContextRoute([.course, .group], subPath: "pages", handler: pagesListFactory)
        addContextRoute([.course, .group], subPath: "wiki", handler: pagesListFactory)

        let moduleItemDetailFactory: (ContextID, [String: Any]) throws -> UIViewController? = { contextID, params in
            guard let query = params["query"] as? [String: Any], let moduleItemID = query["module_item_id"] as? CustomStringConvertible else {
                return nil
            }
            return try ModuleItemDetailViewController(session: currentSession, courseID: contextID.id, moduleItemID: moduleItemID.description, route: route)
        }

        let pageDetailFactory: (ContextID, [String: Any]) throws -> UIViewController? = { contextID, params in
            let url = params["url"] as! String
            return try moduleItemDetailFactory(contextID, params) ?? Page.DetailViewController(session: currentSession, contextID: contextID, url: url, route: route)
        }
        addContextRoute([.course, .group], subPath: "pages/:url", handler: pageDetailFactory)
        addContextRoute([.course, .group], subPath: "wiki/:url", handler: pageDetailFactory)
        addContextRoute([.course, .group], subPath: "front_page") { contextID, _ in
            return try Page.FrontPageDetailViewController(session: currentSession, contextID: contextID, route: route)
        }
        addContextRoute([.course, .group], subPath: "pages_home") { contextID, _ in
            return try PagesHomeViewController(session: currentSession, contextID: contextID, listViewModelFactory: pagesListViewModelFactory, route: route)
        }
        addContextRoute([.course], subPath: "external_tools/:toolID") { contextID, params in
            guard let url = params["url"] as? URL else {
                fatalError("Router passes URL as parameter to route handlers.")
            }
            return LTIViewController(toolName: "", courseID: contextID.id, launchURL: url, in: currentSession, showDoneButton: false)
        }

        // Modules
        addContextRoute([.course], subPath: "modules") { contextID, _ in
            // Restrict access to Modules tab if it's hidden (unless it is the home tab)
            let modulesTab = try Tab.modulesTab(for: contextID, in: currentSession)
            let homeTab = try Tab.homeTab(for: contextID, in: currentSession)
            let modulesAreHome = homeTab != nil && homeTab!.routingURL(currentSession).flatMap { $0.path.contains("/modules") } ?? false
            if !modulesAreHome, modulesTab == nil || modulesTab!.hidden {
                let message = NSLocalizedString("That page has been disabled for this course", comment: "")
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                return alert
            }
            let controller = try ModulesTableViewController(session: currentSession, courseID: contextID.id, route: route)
            return controller
        }
        addContextRoute([.course], subPath: "modules/:id") { contextID, parameters in
            let id = (parameters["id"] as! CustomStringConvertible).description
            let controller = try ModuleDetailsViewController(session: currentSession, courseID: contextID.id, moduleID: id, route: route)
            return controller
        }
        addContextRoute([.course], subPath: "modules/:id/items/:itemID") { contextID, parameters in
            let itemID: String = try parameters.stringID("itemID")
            return try ModuleItemDetailViewController(session: currentSession, courseID: contextID.id, moduleItemID: itemID, route: route)
        }
        // Commonly used in Router+Routes.m in Tech Debt when manually building url from module_item_id query param
        addContextRoute([.course], subPath: "modules/items/:itemID") { contextID, parameters in
            let itemID: String = try parameters.stringID("itemID")
            return try ModuleItemDetailViewController(session: currentSession, courseID: contextID.id, moduleItemID: itemID, route: route)
        }
        addRoute("/conversations/:conversationID") { parameters, _ in
            guard let params = parameters, let convoID = try? params.stringID("conversationID") else {
                fatalError("How did this path match if there is no conversationID?")
            }
            return HelmViewController(moduleName: "/conversations/:conversationID", props: ["conversationID": convoID])
        }
        addRoute("/calendar_events/:calendarEventID") { parameters, _ in
            guard
                let params = parameters,
                let eventID = try? params.stringID("calendarEventID"),
                let eventVC = try? CalendarEventDetailViewController(forEventWithID: eventID, in: currentSession)
            else {
                fatalError("How did this path match if there is no calendarEventID?")
            }
            return eventVC
        }

        CBIConversationStarter.setConversationStarter { recipients, context in
            guard
                let contextID = ContextID(canvasContext: context),
                let enrollment = currentSession.enrollmentsDataSource[contextID] else {
                    return
            }
            HelmManager.shared.present(
                "/conversations/compose",
                withProps: [
                    "recipients": recipients.map { recipient in
                        return [
                            "name": recipient.name,
                            "avatar_url": recipient.avatarURL,
                            "id": recipient.id,
                        ]
                    },
                    "contextCode": context,
                    "contextName": enrollment.name,
                ],
                options: [
                    "modal": true,
                    "embedInNavigationController": true,
                ]
            )
        }
    }
}

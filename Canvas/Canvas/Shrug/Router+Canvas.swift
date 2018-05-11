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

var currentSession: Session? {
    return CanvasKeymaster.the().currentClient?.authSession
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
        
        addContextRoute([.course], subPath: "tabs") { contextID, _ in
            return HelmViewController(
                moduleName: "/courses/:courseID",
                props: ["courseID": contextID.id]
            )
        }

        addRoute("/groups/:groupID") { parameters, _ in
            if let params = parameters, let groupID = try? params.stringID("groupID"), let url = URL(string: "/groups/\(groupID)/tabs") {
                return Router.shared().controller(forHandling: url)
            }
            return nil
        }

        addContextRoute([.group], subPath: "tabs") { contextID, _ in
            guard let currentSession = currentSession else { return nil }
            guard FeatureFlags.featureFlagEnabled(.newGroupNavigation) else {
                return try TabsTableViewController(session: currentSession, contextID: contextID, route: route)
            }
            
            return HelmViewController(
                moduleName: "/groups/:groupID",
                props: ["groupID": contextID.id]
            )
        }
        
        addContextRoute([.course], subPath: "assignments") { contextID, _ in
            return HelmViewController(
                moduleName: "/courses/:courseID/assignments",
                props: ["courseID": contextID.id]
            )
        }
        
        addContextRoute([.course], subPath: "grades") { contextID, _ in
            return HelmViewController(
                moduleName: "/courses/:courseID/grades",
                props: ["courseID": contextID.id]
            )
        }

        // Activity Stream
        addContextRoute([.course, .group], subPath: "activity_stream") { contextID, _ in
            guard let currentSession = currentSession else { return nil }
            return try ActivityStreamTableViewController(session: currentSession, context: contextID, route: route)
        }

        // Pages
        let pagesListViewModelFactory: (Session, Page) -> ColorfulViewModel = { session, page in
            Page.colorfulPageViewModel(session: session, page: page)
        }

        let pagesListFactory: (ContextID, [String: Any]) throws -> UIViewController? = { contextID, _ in
            return HelmViewController(
                moduleName: "/courses/:courseID/pages",
                props: ["courseID": contextID.id]
            )
        }

        let oldPagesListFactory: (ContextID, [String: Any]) throws -> UIViewController? = { contextID, _ in
            guard let currentSession = currentSession else { return nil }
            let controller = try Page.TableViewController(session: currentSession, contextID: contextID, viewModelFactory: pagesListViewModelFactory, route: route)
            return controller
        }

        addContextRoute([.course], subPath: "front_page", handler: pagesListFactory)
        addContextRoute([.course], subPath: "pages", handler: pagesListFactory)
        addContextRoute([.course], subPath: "wiki", handler: pagesListFactory)

        addContextRoute([.group], subPath: "front_page", handler: oldPagesListFactory)
        addContextRoute([.group], subPath: "pages", handler: oldPagesListFactory)
        addContextRoute([.group], subPath: "wiki", handler: oldPagesListFactory)
        
        let fileListFactory = { (contextID: ContextID) -> UIViewController in
            var props = ["context": contextID.context.pathComponent, "contextID": contextID.id]
            if contextID.context == .user {
                props["customPageViewPath"] = "/files"
            }
            return HelmViewController(moduleName: "/:context/:contextID/files", props: props)
        }

        addRoute("/files") { parameters, _ in
            if let parameters = parameters, let query = parameters["query"] as? Dictionary<String, Any>,
                let fileID = query["preview"] as? String,
                let url = URL(string: "/files/\(fileID)") {
                // route to native file details
                return Router.shared().controller(forHandling: url)
            }

            if let url = URL(string: "/users/self/files") {
                return Router.shared().controller(forHandling: url)
            }

            return nil
        }

        addRoute("/files/folder/*subFolder") { parameters, _ in
            if  let subFolder = parameters?["subFolder"] as? String,
                let url = URL(string: "/users/self/files/folder/\(subFolder)") {
                return Router.shared().controller(forHandling: url)
            }

            return nil
        }
        
        addContextRoute([.course, .group, .user], subPath: "files") { contextID, params in
            if let query = params["query"] as? Dictionary<String, Any>,
                let fileID = query["preview"] as? String,
                let url = URL(string: "/\(contextID.context.pathComponent)/\(contextID.id)/files/\(fileID)") {
                    // route to native file details
                    return Router.shared().controller(forHandling: url)
            }
            
            return fileListFactory(contextID)
        }
        
        addContextRoute([.course, .group, .user], subPath: "files/folder/*subFolder") { contextID, params in
            if let query = params["query"] as? Dictionary<String, Any>,
                let fileID = query["preview"] as? String,
                let url = URL(string: "/courses/\(contextID.id)/files/\(fileID)") {
                    // route to native file details
                    return Router.shared().controller(forHandling: url)
            }
            
            if let subFolder = params["subFolder"] as? String {
                return HelmViewController(
                    moduleName: "/:context/:contextID/files/folder/*subFolder",
                    props: ["context": contextID.context.pathComponent, "contextID": contextID.id, "subFolder": subFolder]
                )
            }
            
            return fileListFactory(contextID)
        }
        
        addContextRoute([.course, .group, .user], subPath: "folders/:folderID") { contextID, params in
            guard let folderID = params["folderID"] as? String else { return fileListFactory(contextID) }
            if folderID == "root" { return fileListFactory(contextID) }
            // We don't support routing to a specific folderID yet, that's to come later
            return fileListFactory(contextID)
        }
        
        addRoute("/courses/:courseID") { parameters, _ in
            guard let params = parameters, let courseID = (try? params.stringID("courseID")) else { return nil }
            return HelmViewController(moduleName: "/courses/:courseID", props: ["courseID": courseID])
        }
        
        let moduleItemDetailFactory: (ContextID, [String: Any]) throws -> UIViewController? = { contextID, params in
            guard let query = params["query"] as? [String: Any], let moduleItemID = query["module_item_id"] as? CustomStringConvertible, let currentSession = currentSession else {
                return nil
            }
            return try ModuleItemDetailViewController(session: currentSession, courseID: contextID.id, moduleItemID: moduleItemID.description, route: route)
        }

        let pageDetailFactory: (ContextID, [String: Any]) throws -> UIViewController? = { contextID, params in
            let url = params["url"] as! String
            if let moduleItemDetail = try moduleItemDetailFactory(contextID, params) {
                return moduleItemDetail
            }
            guard let currentSession = currentSession else { return nil }
            return try Page.DetailViewController(session: currentSession, contextID: contextID, url: url, route: route)
        }
        addContextRoute([.group], subPath: "pages/:url", handler: pageDetailFactory)
        addContextRoute([.group], subPath: "wiki/:url", handler: pageDetailFactory)

        addContextRoute([.course], subPath: "pages_home") { contextID, _ in
            return HelmViewController(moduleName: "/courses/:courseID/pages", props: ["courseID": contextID.id])
        }
        addContextRoute([.group], subPath: "pages_home") { contextID, _ in
            guard let currentSession = currentSession else { return nil }
            return try PagesHomeViewController(session: currentSession, contextID: contextID, listViewModelFactory: pagesListViewModelFactory, route: route)
        }

        addContextRoute([.course], subPath: "external_tools/:toolID") { contextID, params in
            guard let url = params["url"] as? URL,
                    let session = currentSession,
                    let vc = HelmManager.shared.topMostViewController() else { return nil }
            
            ExternalToolManager.shared.launch(url, in: session, from: vc, fallbackURL: url)
            return nil
        }

        // Discussions
        let topics: (ContextID, [String: Any]) -> UIViewController = { contextID, _ in
            return HelmViewController(
                moduleName: "/:context/:contextID/discussion_topics",
                props: contextID.props
            )
        }
        let announcementsHandler: (ContextID, [String: Any]) -> UIViewController = { contextID, _ in
            return HelmViewController(
                moduleName: "/:context/:contextID/announcements",
                props: contextID.props
            )
        }
        addContextRoute([.course, .group], subPath: "discussion_topics", handler: topics)
        addContextRoute([.course, .group], subPath: "discussions", handler: topics)
        addContextRoute([.course, .group], subPath: "announcements", handler: announcementsHandler)
        let discussion: (ContextID, [String: Any]) throws -> UIViewController = { contextID, params in
            let discussionID: String = try params.stringID("discussionID")
            var props = contextID.props
            props["discussionID"] = discussionID
            return HelmViewController(
                moduleName: "/:context/:contextID/discussion_topics/:discussionID",
                props: props
            )
        }
        addContextRoute([.course, .group], subPath: "discussion_topics/:discussionID", handler: discussion)
        addContextRoute([.course, .group], subPath: "discussions/:discussionID", handler: discussion)

        let announcement: (ContextID, [String: Any]) throws -> UIViewController = { contextID, params in
            let announcementID: String = try params.stringID("announcementID")
            var props = contextID.props
            props["announcementID"] = announcementID
            return HelmViewController(
                moduleName: "/:context/:contextID/announcements/:announcementID",
                props: props
            )
        }
        addContextRoute([.course, .group], subPath: "announcements/:announcementID", handler: announcement)

        // Modules
        addContextRoute([.course], subPath: "modules") { contextID, _ in
            // Restrict access to Modules tab if it's hidden (unless it is the home tab)
            guard let currentSession = currentSession else { return nil }
            let modulesTab = try Tab.modulesTab(for: contextID, in: currentSession)
            let homeTab = try Tab.homeTab(for: contextID, in: currentSession)
            let modulesAreHome = homeTab != nil && homeTab!.routingURL(currentSession).flatMap { $0.path.contains("/modules") } ?? false
            if !modulesAreHome, modulesTab?.hidden ?? false {
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
            guard let currentSession = currentSession else { return nil }
            let controller = try ModuleDetailsViewController(session: currentSession, courseID: contextID.id, moduleID: id, route: route)
            return controller
        }
        addContextRoute([.course], subPath: "modules/:id/items/:itemID") { contextID, parameters in
            let itemID: String = try parameters.stringID("itemID")
            guard let currentSession = currentSession else { return nil }
            return try ModuleItemDetailViewController(session: currentSession, courseID: contextID.id, moduleItemID: itemID, route: route)
        }
        // Commonly used in Router+Routes.m in Tech Debt when manually building url from module_item_id query param
        addContextRoute([.course], subPath: "modules/items/:itemID") { contextID, parameters in
            let itemID: String = try parameters.stringID("itemID")
            guard let currentSession = currentSession else { return nil }
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
                let currentSession = currentSession,
                let eventVC = try? CalendarEventDetailViewController(forEventWithID: eventID, in: currentSession, route: route)
            else {
                fatalError("How did this path match if there is no calendarEventID?")
            }
            return eventVC
        }

        CBIConversationStarter.setConversationStarter { recipients, context in
            guard
                let contextID = ContextID(canvasContext: context),
                let currentSession = currentSession,
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

extension ContextID {
    var props: [String: Any] {
        switch context {
        case .course:
            return ["context": "courses", "contextID": id]
        case .group:
            return ["context": "groups", "contextID": id]
        case .account:
            return ["context": "accounts", "contextID": id]
        case .user:
            return ["context": "users", "contextID": id]
        }
    }
}
